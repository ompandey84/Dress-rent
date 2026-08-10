import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/product.dart';
import 'package:dress_app/screens/booking_summary_screen.dart';
import 'package:dress_app/models/cart_item.dart';
import 'package:intl/intl.dart';

class SelectDatesScreen extends StatefulWidget {
  final Product product;
  final String? selectedSize;
  final String? selectedColor;
  const SelectDatesScreen({
    super.key,
    required this.product,
    this.selectedSize,
    this.selectedColor,
  });

  @override
  State<SelectDatesScreen> createState() => _SelectDatesScreenState();
}

class _SelectDatesScreenState extends State<SelectDatesScreen> {
  // Real DateTime objects — calendar math is correct (handles month lengths,
  // leap years, year rollover).
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _visibleMonth; // first day of the month currently shown

  @override
  void initState() {
    super.initState();
    final today = _today();
    _visibleMonth = DateTime(today.year, today.month, 1);
    // Default to today + 2 → today + 4 so the price preview isn't blank.
    _startDate = today.add(const Duration(days: 2));
    _endDate = today.add(const Duration(days: 4));
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  int get _rentalDays {
    if (_startDate == null || _endDate == null) return 0;
    // Inclusive of both pickup and return: end - start + 1
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  double get _rentalPrice => _rentalDays * widget.product.rentalPricePerDay;

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
  }

  void _prevMonth() {
    final today = _today();
    final prev = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    // Don't allow scrolling into months fully before today
    if (prev.isBefore(DateTime(today.year, today.month, 1))) return;
    setState(() {
      _visibleMonth = prev;
    });
  }

  void _onDayTapped(DateTime day) {
    final today = _today();
    if (day.isBefore(today)) return; // past date
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Start a fresh range
        _startDate = day;
        _endDate = null;
      } else {
        // We have a start but no end
        if (day.isBefore(_startDate!)) {
          // Tapped before start → reset start
          _startDate = day;
        } else {
          _endDate = day;
        }
      }
    });
  }

  bool _isStart(DateTime day) =>
      _startDate != null && _isSameDay(day, _startDate!);
  bool _isEnd(DateTime day) =>
      _endDate != null && _isSameDay(day, _endDate!);
  bool _isInRange(DateTime day) {
    if (_startDate == null || _endDate == null) return false;
    return day.isAfter(_startDate!) && day.isBefore(_endDate!);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(DateTime d) {
    return DateFormat('MMMM yyyy').format(d);
  }

  String _dateLabel(DateTime? d) {
    if (d == null) return 'Select';
    return DateFormat('d MMM').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            FluentIcons.chevron_left_24_regular,
            color: AppTheme.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SELECT DATES',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'When do you need it?',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick a start and end date. Price updates as you choose.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // Selected-range summary (always visible)
                _buildRangeSummary(),
                const SizedBox(height: 16),

                _buildCalendar(),
                const SizedBox(height: 16),
                _buildLegend(),

                const SizedBox(height: 16),
                _buildPricePreview(),
              ],
            ),
          ),

          // Floating Bottom Button
          Positioned(
            bottom: 15,
            left: 20,
            right: 20,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryLime.withOpacity(0.3),
                    offset: const Offset(0, 8),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (_startDate == null || _endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select both pickup and return dates',
                        ),
                      ),
                    );
                    return;
                  }
                  final cartItem = CartItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    product: widget.product,
                    selectedSize: widget.selectedSize ??
                        (widget.product.sizes.isNotEmpty
                            ? widget.product.sizes.first
                            : 'M'),
                    selectedColor: widget.selectedColor ??
                        (widget.product.colors.isNotEmpty
                            ? widget.product.colors.first
                            : 'Default'),
                    rentalStartDate: _startDate!,
                    rentalEndDate: _endDate!,
                    quantity: 1,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingSummaryScreen(
                        product: widget.product,
                        cartItem: cartItem,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Center(
                  child: Text(
                    'NEXT: ORDER PREPARATION',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PICKUP',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _dateLabel(_startDate),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _startDate == null
                        ? AppTheme.textLight
                        : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: AppTheme.border,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RETURN',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dateLabel(_endDate),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _endDate == null
                          ? AppTheme.textLight
                          : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    // Compute leading blanks so the 1st of the month lands under the right weekday.
    final firstDayOfMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day; // Day 0 of next month = last day of this month
    final leadingBlanks = firstDayOfMonth.weekday % 7; // Sunday=0

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: Icon(
                  FluentIcons.chevron_left_24_regular,
                  size: 18,
                  color: _canGoPrev()
                      ? AppTheme.textDark
                      : Colors.grey.shade300,
                ),
              ),
              Text(
                _monthName(_visibleMonth),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(
                  FluentIcons.chevron_right_24_regular,
                  size: 18,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (d) => SizedBox(
                    width: 32,
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - leadingBlanks + 1;
              final day = DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                dayNumber,
              );
              return _buildDayCell(day);
            },
          ),
        ],
      ),
    );
  }

  bool _canGoPrev() {
    final today = _today();
    final firstOfThis = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final firstOfPrev = DateTime(
      _visibleMonth.year,
      _visibleMonth.month - 1,
      1,
    );
    return !firstOfPrev.isBefore(DateTime(today.year, today.month, 1)) &&
        firstOfPrev.isBefore(firstOfThis);
  }

  Widget _buildDayCell(DateTime day) {
    final today = _today();
    final isPast = day.isBefore(today);
    final isStart = _isStart(day);
    final isEnd = _isEnd(day);
    final isInRange = _isInRange(day);

    Color bgColor = Colors.transparent;
    Color textColor = AppTheme.textDark;
    BoxShape shape = BoxShape.circle;

    if (isStart || isEnd) {
      bgColor = AppTheme.primaryLime;
      textColor = AppTheme.textDark;
    } else if (isInRange) {
      bgColor = AppTheme.primaryLime.withValues(alpha: 0.25);
      textColor = AppTheme.textDark;
      shape = BoxShape.rectangle;
    } else if (isPast) {
      textColor = Colors.grey.shade400;
    } else if (_isSameDay(day, today)) {
      textColor = AppTheme.textDark;
    }

    return GestureDetector(
      onTap: isPast ? null : () => _onDayTapped(day),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(6)
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          day.day.toString(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: (isStart || isEnd)
                ? FontWeight.w900
                : FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(AppTheme.primaryLime, 'Start/End'),
        const SizedBox(width: 14),
        _legendDot(
          AppTheme.primaryLime.withValues(alpha: 0.25),
          'Rental period',
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppTheme.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPricePreview() {
    final days = _rentalDays;
    final price = _rentalPrice;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.textDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RENTAL DURATION',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: Colors.white60,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                days == 0
                    ? '—'
                    : '$days day${days == 1 ? '' : 's'}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryLime,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'EST. RENTAL',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: Colors.white60,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                days == 0
                    ? '₹ 0'
                    : '₹ ${price.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryLime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
