import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

import '../../state/theme_provider.dart';
import '../../state/listings_provider.dart';
import 'gradient_button.dart';
import '../../data/models/listing.dart';
import '../../data/models/booking.dart';
import '../../data/services/listings_service.dart';
import '../../data/services/notification_service.dart';
import '../../state/auth_provider.dart';

class BookingModal extends ConsumerStatefulWidget {
  final Listing listing;
  final VoidCallback onClose;

  const BookingModal({
    super.key,
    required this.listing,
    required this.onClose,
  });

  @override
  ConsumerState<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends ConsumerState<BookingModal> {
  int _step = 0; // 0: form, 1: payment, 2: success
  int _participants = 1;
  String _specialRequests = '';
  AvailabilitySlot? _selectedSlot;
  String? _selectedDate;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    if (!authState.isAuthenticated) {
      return _buildLoginRequired(isDark);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isDark),
          _buildListingInfo(isDark),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 32),
          const Icon(
            Icons.person_outline,
            size: 64,
            color: AppColors.kAccentMint,
          ),
          const SizedBox(height: 16),
          Text(
            'Login Required',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textColor(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please login to make a booking',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Login',
            onPressed: () {
              widget.onClose();
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor(isDark)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _getStepTitle(),
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textColor(isDark),
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              LucideIcons.x,
              color: AppColors.textColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderColor(isDark)),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.listing.images.first,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: AppColors.cardColor(isDark),
                child: Icon(
                  LucideIcons.image,
                  color: AppColors.textSecondaryColor(isDark),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listing.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.listing.location.address,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryColor(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.listing.price.toStringAsFixed(0)} MAD per person',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.kAccentMint,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(bool isDark) {
    switch (_step) {
      case 0:
        return _buildBookingForm(isDark);
      case 1:
        return _buildPaymentForm(isDark);
      case 2:
        return _buildSuccessMessage(isDark);
      default:
        return _buildBookingForm(isDark);
    }
  }

  Widget _buildBookingForm(bool isDark) {
    // Group availability slots by date
    final availabilityByDate = <String, List<AvailabilitySlot>>{};
    for (final slot in widget.listing.availability) {
      final date = DateTime.parse(slot.dateSlotStart);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      availabilityByDate[dateKey] ??= [];
      availabilityByDate[dateKey]!.add(slot);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.kAlertRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.kAlertRed),
            ),
            child: Text(
              _error!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.kAlertRed,
              ),
            ),
          ),
        ],

        // Date & Time Selection
        Text(
          'Choose Date & Time',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor(isDark),
          ),
        ),
        const SizedBox(height: 16),

        if (availabilityByDate.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardColor(isDark).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 48,
                  color: AppColors.textSecondaryColor(isDark),
                ),
                const SizedBox(height: 16),
                Text(
                  'No availability slots',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor(isDark),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check back later or contact the host',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryColor(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...availabilityByDate.entries.map((entry) {
            final date = entry.key;
            final slots =
                entry.value.where((slot) => slot.isAvailable).toList();

            if (slots.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardColor(isDark).withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedDate == date
                      ? AppColors.kAccentMint
                      : AppColors.borderColor(isDark),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(DateTime.parse(date)),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: slots.map((slot) {
                      final startTime = DateTime.parse(slot.dateSlotStart);
                      final timeString = DateFormat('HH:mm').format(startTime);
                      final isSelected = _selectedSlot?.slotId == slot.slotId;
                      final slotsLeft = slot.capacity - slot.bookedCount;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSlot = slot;
                            _selectedDate = date;
                            _error = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.kAccentMint
                                : AppColors.cardColor(isDark).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.kAccentMint
                                  : AppColors.borderColor(isDark),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.clock,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.black
                                        : AppColors.textColor(isDark),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    timeString,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isSelected
                                          ? Colors.black
                                          : AppColors.textColor(isDark),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.users,
                                    size: 12,
                                    color: isSelected
                                        ? Colors.black.withOpacity(0.7)
                                        : AppColors.textSecondaryColor(isDark),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$slotsLeft left',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isSelected
                                          ? Colors.black.withOpacity(0.7)
                                          : AppColors.textSecondaryColor(
                                              isDark),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),

        const SizedBox(height: 24),

        // Participants
        Text(
          'Number of Participants',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor(isDark),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardColor(isDark).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _participants > 1
                    ? () => setState(() => _participants--)
                    : null,
                icon:
                    Icon(LucideIcons.minus, color: AppColors.textColor(isDark)),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.cardColor(isDark).withOpacity(0.5),
                ),
              ),
              Expanded(
                child: Text(
                  _participants.toString(),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _participants++),
                icon:
                    Icon(LucideIcons.plus, color: AppColors.textColor(isDark)),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.cardColor(isDark).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Special Requests
        Text(
          'Special Requests (Optional)',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor(isDark),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => _specialRequests = value,
          decoration: InputDecoration(
            hintText: 'Any special requests or notes...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor(isDark),
            ),
            filled: true,
            fillColor: AppColors.cardColor(isDark).withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.kAccentMint),
            ),
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textColor(isDark),
          ),
          maxLines: 3,
        ),

        const SizedBox(height: 32),

        // Continue Button
        GradientButton(
          text: 'Continue',
          isLoading: _isLoading,
          onPressed: _selectedSlot != null ? _handleContinue : null,
        ),
      ],
    );
  }

  Widget _buildPaymentForm(bool isDark) {
    final totalPrice = widget.listing.price * _participants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Booking Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardColor(isDark).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Summary',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor(isDark),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedSlot != null && _selectedDate != null) ...[
                _buildSummaryRow(
                  'Date',
                  DateFormat('EEEE, MMMM d, y')
                      .format(DateTime.parse(_selectedDate!)),
                  isDark,
                ),
                _buildSummaryRow(
                  'Time',
                  DateFormat('HH:mm')
                      .format(DateTime.parse(_selectedSlot!.dateSlotStart)),
                  isDark,
                ),
                _buildSummaryRow(
                  'Participants',
                  '$_participants participant${_participants > 1 ? 's' : ''}',
                  isDark,
                ),
                Divider(color: AppColors.borderColor(isDark)),
                _buildSummaryRow(
                  'Total',
                  '$totalPrice MAD',
                  isDark,
                  isTotal: true,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Payment Info (Mock)
        Text(
          'Payment Information',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textColor(isDark),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.kAccentMint.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.kAccentMint),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.credit_card,
                size: 48,
                color: AppColors.kAccentMint,
              ),
              const SizedBox(height: 12),
              Text(
                'Demo Payment',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.kAccentMint,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This is a demo app. No real payment will be processed.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.kAccentMint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Payment Button
        GradientButton(
          text: 'Pay $totalPrice MAD',
          isLoading: _isLoading,
          onPressed: _handlePayment,
        ),

        const SizedBox(height: 16),

        // Back Button
        TextButton(
          onPressed: () => setState(() => _step = 0),
          child: Text(
            'Back',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.kAccentMint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 32),
        const Icon(
          Icons.check_circle,
          size: 80,
          color: AppColors.kAccentMint,
        ),
        const SizedBox(height: 24),
        Text(
          'Booking Confirmed!',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.kAccentMint,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your booking has been confirmed. You will receive a confirmation email shortly.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryColor(isDark),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        GradientButton(
          text: 'Done',
          onPressed: () {
            // Final refresh to ensure bookings are up to date
            ref.invalidate(bookingsProvider);
            widget.onClose();
          },
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryColor(isDark),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color:
                  isTotal ? AppColors.kAccentMint : AppColors.textColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_step) {
      case 0:
        return 'Book Experience';
      case 1:
        return 'Payment';
      case 2:
        return 'Booking Confirmed';
      default:
        return 'Book Experience';
    }
  }

  void _handleContinue() {
    if (_selectedSlot == null) {
      setState(() {
        _error = 'Please select a time slot';
      });
      return;
    }

    setState(() {
      _step = 1;
      _error = null;
    });
  }

  void _handlePayment() async {
    if (_selectedSlot == null || _selectedDate == null) {
      setState(() {
        _error = 'Invalid booking details';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final listingsService = ListingsService();
      final startTime = DateTime.parse(_selectedSlot!.dateSlotStart);
      final formattedTime = DateFormat('HH:mm').format(startTime);

      await listingsService.createBooking(
        listingId: int.parse(widget.listing.id),
        slotId: _selectedSlot!.slotId,
        date: _selectedDate!,
        time: formattedTime,
        participants: _participants,
        specialRequests: _specialRequests.isNotEmpty ? _specialRequests : null,
      );

      setState(() {
        _step = 2;
        _isLoading = false;
      });

      // ✅ CRITICAL: Refresh bookings provider to show new booking immediately
      ref.invalidate(bookingsProvider);

      // Show success notification
      NotificationService.showBookingConfirmation(
        context,
        listingTitle: widget.listing.title,
        date: DateFormat('MMM dd, yyyy').format(DateTime.parse(_selectedDate!)),
        time: formattedTime,
        participants: _participants,
        totalPrice: widget.listing.price * _participants,
      );

      // Also show a dialog for immediate feedback
      Future.delayed(const Duration(milliseconds: 500), () {
        NotificationService.showNotificationDialog(
          context,
          title: 'Booking Confirmed!',
          message:
              'Your booking for ${widget.listing.title} has been confirmed. You will receive a confirmation email shortly.',
          type: NotificationType.success,
          primaryButtonText: 'View Booking',
          onPrimaryPressed: () {
            // Ensure bookings are refreshed before navigating
            ref.invalidate(bookingsProvider);
            Navigator.of(context).pop(); // Close dialog
            widget.onClose(); // Close modal
            context.goNamed('profile'); // Go to profile/bookings
          },
          secondaryButtonText: 'Done',
          onSecondaryPressed: () {
            // Final refresh before closing
            ref.invalidate(bookingsProvider);
            Navigator.of(context).pop(); // Close dialog
            widget.onClose(); // Close modal
          },
        );
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      // Show error notification
      NotificationService.showBookingError(context, e.toString());
    }
  }
}
