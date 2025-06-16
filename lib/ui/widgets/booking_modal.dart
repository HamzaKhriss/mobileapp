import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../data/mock_data.dart';
import '../../state/theme_provider.dart';
import 'gradient_button.dart';

class BookingModal extends ConsumerStatefulWidget {
  final MockListing listing;

  const BookingModal({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends ConsumerState<BookingModal> {
  DateTime? _selectedDate;
  String? _selectedTime;
  int _adults = 1;
  int _children = 0;
  int _infants = 0;

  final List<String> _availableTimes = [
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM'
  ];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: AppColors.borderColor(isDark),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Book ${widget.listing.title}',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textColor(isDark),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    LucideIcons.x,
                    color: AppColors.textColor(isDark),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time selection
                  Text(
                    'When',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDateSelector(
                    widget.listing.category == 'restaurant'
                        ? 'Reservation Date'
                        : 'Event Date',
                    _selectedDate,
                    isDark,
                    () => _selectDate(),
                  ),
                  const SizedBox(height: 16),
                  if (widget.listing.category == 'restaurant') ...[
                    Text(
                      'Time',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTimes.map((time) {
                        final isSelected = _selectedTime == time;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTime = time;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.kAccentMint
                                  : AppColors.cardColor(isDark),
                              borderRadius: BorderRadius.circular(20),
                              border: !isSelected
                                  ? Border.all(
                                      color: AppColors.borderColor(isDark),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Text(
                              time,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isSelected
                                    ? Colors.black
                                    : AppColors.textColor(isDark),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Guest selection
                  Text(
                    'Who',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGuestSelector('Adults', _adults, isDark, (value) {
                    setState(() {
                      _adults = value;
                    });
                  }),
                  const SizedBox(height: 16),
                  _buildGuestSelector('Children', _children, isDark, (value) {
                    setState(() {
                      _children = value;
                    });
                  }),
                  const SizedBox(height: 16),
                  _buildGuestSelector('Infants', _infants, isDark, (value) {
                    setState(() {
                      _infants = value;
                    });
                  }),
                  const SizedBox(height: 32),

                  // Price breakdown
                  if (_selectedDate != null &&
                      (widget.listing.category == 'event' ||
                          _selectedTime != null)) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor(isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderColor(isDark),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total for ${_getTotalGuests()} ${_getTotalGuests() == 1 ? 'person' : 'people'}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textColor(isDark),
                                ),
                              ),
                              Text(
                                '${_calculateTotal().toInt()} MAD',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.kAccentMint,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: GradientButton(
                text: 'Confirm Booking',
                onPressed: _canBook()
                    ? () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Booking confirmed! 🎉'),
                            backgroundColor: AppColors.kAccentMint,
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
      String label, DateTime? date, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor(isDark)),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.cardColor(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryColor(isDark),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? DateFormat('MMM dd').format(date) : 'Select date',
              style: AppTextStyles.bodyMedium.copyWith(
                color: date != null
                    ? AppColors.textColor(isDark)
                    : AppColors.textSecondaryColor(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSelector(
      String label, int count, bool isDark, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textColor(isDark),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: count > (label == 'Adults' ? 1 : 0)
                  ? () => onChanged(count - 1)
                  : null,
              icon: Icon(
                LucideIcons.minus,
                color: AppColors.textSecondaryColor(isDark),
              ),
            ),
            Text(
              count.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textColor(isDark),
              ),
            ),
            IconButton(
              onPressed: () => onChanged(count + 1),
              icon: const Icon(
                LucideIcons.plus,
                color: AppColors.kAccentMint,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.kAccentMint,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  int _getTotalGuests() {
    return _adults + _children + _infants;
  }

  double _calculateTotal() {
    return widget.listing.price * _getTotalGuests();
  }

  bool _canBook() {
    if (widget.listing.category == 'restaurant') {
      return _selectedDate != null && _selectedTime != null && _adults > 0;
    } else {
      return _selectedDate != null && _adults > 0;
    }
  }
}
