import 'package:flutter/material.dart';

/// Helper that shows the rounded modal bottom sheet used across the page.
Future<DateTime?> _showCalendarBottomSheet(BuildContext ctx) {
  final radius = 28.0;
  // open the sheet to roughly the middle of the screen (50%) with a rounded top
  return showModalBottomSheet<DateTime>(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (c) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              // force the sheet to be exactly half the screen height so there is no gap
              constraints: BoxConstraints.tightFor(
                height: MediaQuery.of(ctx).size.height * 0.5,
              ),
              child: const _CalendarBottomSheet(),
            ),
          ),
        ),
      );
    },
  );
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2DA84A), // green similar to screenshot
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputPlaceholder(String text) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(
          0xFFECECF3,
        ), // light lavender-ish background to match screenshot
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Calendar is a touch optimized component that provides an easy way to handle dates.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Calendar could be used as inline component or as overlay. Overlay Calendar will be automatically converted to Popover on tablets (iPad).',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 20),

              _sectionTitle('Default setup'),
              GestureDetector(
                onTap: () async {
                  final result = await _showCalendarBottomSheet(context);
                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Selected: ${result.toLocal().toIso8601String().split('T').first}',
                        ),
                      ),
                    );
                  }
                },
                child: _inputPlaceholder('Your birth date'),
              ),

              const SizedBox(height: 20),
              _sectionTitle('Custom date format'),
              GestureDetector(
                onTap: () async {
                  final result = await _showCalendarBottomSheet(context);
                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Selected: ${result.toLocal().toIso8601String().split('T').first}',
                        ),
                      ),
                    );
                  }
                },
                child: _inputPlaceholder('Select date'),
              ),

              const SizedBox(height: 20),
              _sectionTitle('Date + Time'),
              GestureDetector(
                onTap: () async {
                  final result = await _showCalendarBottomSheet(context);
                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Selected: ${result.toLocal().toIso8601String().split('T').first}',
                        ),
                      ),
                    );
                  }
                },
                child: _inputPlaceholder('Select date and time'),
              ),

              const SizedBox(height: 20),
              _sectionTitle('Multiple Values'),
              GestureDetector(
                onTap: () async {
                  final result = await _showCalendarBottomSheet(context);
                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Selected: ${result.toLocal().toIso8601String().split('T').first}',
                        ),
                      ),
                    );
                  }
                },
                child: _inputPlaceholder('Select multiple dates'),
              ),

              const SizedBox(height: 20),
              _sectionTitle('Range Picker'),
              GestureDetector(
                onTap: () async {
                  final result = await _showCalendarBottomSheet(context);
                  if (result != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Selected: ${result.toLocal().toIso8601String().split('T').first}',
                        ),
                      ),
                    );
                  }
                },
                child: _inputPlaceholder('Select date range'),
              ),

              const SizedBox(height: 20),
              _sectionTitle('Open in Modal'),
              GestureDetector(
                onTap: () async {
                  final picked = await showDialog<DateTime?>(
                    context: context,
                    builder: (ctx) {
                      const radius = 28.0;
                      return Dialog(
                        insetPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: SizedBox(
                            // approximate height similar to the screenshot
                            height: 520,
                            child: const _CalendarBottomSheet(),
                          ),
                        ),
                      );
                    },
                  );

                  if (picked != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Selected: ${picked.toLocal().toIso8601String().split('T').first}',
                        ),
                      ),
                    );
                  }
                },
                child: _inputPlaceholder('Select date'),
              ),

              const SizedBox(height: 20),
              _sectionTitle('Calendar Page'),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: const Text('Open Calendar Page'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CalendarFullPage()),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _sectionTitle('Inline with custom toolbar'),
              const SizedBox(height: 8),
              // Inline calendar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const CalendarInlineWidget(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class CalendarInlineWidget extends StatefulWidget {
  const CalendarInlineWidget({Key? key}) : super(key: key);

  @override
  State<CalendarInlineWidget> createState() => _CalendarInlineWidgetState();
}

class _CalendarInlineWidgetState extends State<CalendarInlineWidget> {
  DateTime _displayed = DateTime(DateTime.now().year, DateTime.now().month + 1);
  DateTime? _selected;

  final List<String> _monthNames = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now();
  }

  void _prev() {
    setState(() {
      _displayed = DateTime(_displayed.year, _displayed.month - 1);
    });
  }

  void _next() {
    setState(() {
      _displayed = DateTime(_displayed.year, _displayed.month + 1);
    });
  }

  int _daysInMonth(DateTime m) {
    final next = (m.month == 12)
        ? DateTime(m.year + 1, 1)
        : DateTime(m.year, m.month + 1);
    return DateTime(next.year, next.month, 0).day;
  }

  int _firstWeekday(DateTime m) => DateTime(m.year, m.month, 1).weekday;

  Widget _dayCellWidget(
    int day, {
    bool muted = false,
    bool isSelected = false,
    DateTime? date,
  }) {
    final textColor = muted
        ? Colors.grey.shade400
        : (isSelected ? Colors.white : Colors.black87);
    final circleColor = isSelected
        ? const Color(0xFF2DA84A)
        : Colors.transparent;

    final child = Container(
      margin: const EdgeInsets.all(6),
      height: 44,
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );

    if (date != null) {
      return GestureDetector(
        onTap: () => setState(() => _selected = date),
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final year = _displayed.year;
    final month = _displayed.month;
    final days = _daysInMonth(_displayed);
    final leading = _firstWeekday(_displayed) - 1;

    final List<Widget> cells = [];
    // previous month tail
    final prevMonthLastDay = DateTime(year, month, 0).day;
    for (int i = 0; i < leading; i++) {
      final day = prevMonthLastDay - (leading - 1) + i;
      cells.add(_dayCellWidget(day, muted: true));
    }
    for (int d = 1; d <= days; d++) {
      final date = DateTime(year, month, d);
      final isSelected =
          _selected != null &&
          _selected!.year == date.year &&
          _selected!.month == date.month &&
          _selected!.day == date.day;
      cells.add(
        _dayCellWidget(d, muted: false, isSelected: isSelected, date: date),
      );
    }
    int remainder = cells.length % 7;
    if (remainder != 0) {
      final toAdd = 7 - remainder;
      for (int i = 1; i <= toAdd; i++)
        cells.add(_dayCellWidget(i, muted: true));
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(color: Color(0xFFF3F5F9)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: _prev,
              ),
              Text(
                '${_monthNames[month - 1]}, $year',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _next,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Mon', style: TextStyle(color: Colors.black54)),
              Text('Tue', style: TextStyle(color: Colors.black54)),
              Text('Wed', style: TextStyle(color: Colors.black54)),
              Text('Thu', style: TextStyle(color: Colors.black54)),
              Text('Fri', style: TextStyle(color: Colors.black54)),
              Text('Sat', style: TextStyle(color: Colors.black54)),
              Text('Sun', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          color: const Color(0xFFF3F5F9),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: GridView.count(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),
        ),
      ],
    );
  }
}

class CalendarFullPage extends StatefulWidget {
  const CalendarFullPage({Key? key}) : super(key: key);

  @override
  State<CalendarFullPage> createState() => _CalendarFullPageState();
}

class _CalendarFullPageState extends State<CalendarFullPage> {
  DateTime _displayed = DateTime.now();
  // Full page displays calendar + events list (only on this page)

  final List<Map<String, Object>> _events = [
    {
      'title': 'Meeting with Vladimir',
      'time': '12:30',
      'color': const Color(0xFF42A5F5),
      'date': DateTime.now(),
    },
    {
      'title': 'Shopping',
      'time': '18:00',
      'color': const Color(0xFF2DA84A),
      'date': DateTime.now(),
    },
    {
      'title': 'Gym',
      'time': '21:00',
      'color': const Color(0xFFEC407A),
      'date': DateTime.now(),
    },
  ];

  String get _monthYearLabel {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${monthNames[_displayed.month - 1]}, ${_displayed.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // custom header matching screenshot
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _monthYearLabel,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // keep symmetry with back button
                ],
              ),
            ),

            // small divider
            Container(height: 1, color: Colors.grey.shade200),

            // calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: const CalendarInlineWidget(),
            ),

            // events list shown only on the full page
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: _events.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final ev = _events[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 14.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 48,
                            decoration: BoxDecoration(
                              color: ev['color'] as Color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ev['title'] as String,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            ev['time'] as String,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarBottomSheet extends StatefulWidget {
  const _CalendarBottomSheet({Key? key}) : super(key: key);

  @override
  State<_CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<_CalendarBottomSheet> {
  DateTime _displayed = DateTime.now();
  DateTime? _selected;

  // no inline events for the modal — modal shows only the calendar

  final List<String> _monthNames = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  void _prev() {
    setState(() {
      _displayed = DateTime(_displayed.year, _displayed.month - 1);
    });
  }

  void _next() {
    setState(() {
      _displayed = DateTime(_displayed.year, _displayed.month + 1);
    });
  }

  @override
  void initState() {
    super.initState();
    _selected = DateTime.now();
  }

  Widget _dayCell(
    int day, {
    bool muted = false,
    bool isSelected = false,
    DateTime? onTapDate,
  }) {
    final textColor = muted
        ? Colors.grey.shade400
        : (isSelected ? Colors.white : Colors.black87);
    final circleColor = isSelected
        ? const Color(0xFF2DA84A)
        : Colors.transparent;

    final child = Container(
      margin: const EdgeInsets.all(6),
      height: 44,
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );

    if (onTapDate != null) {
      return GestureDetector(
        onTap: () {
          setState(() => _selected = onTapDate);
          // close the sheet immediately and return the tapped date
          Navigator.of(context).pop(onTapDate);
        },
        child: child,
      );
    }
    return child;
  }

  int _daysInMonth(DateTime m) {
    final firstNext = (m.month == 12)
        ? DateTime(m.year + 1, 1)
        : DateTime(m.year, m.month + 1);
    return DateTime(firstNext.year, firstNext.month, 0).day;
  }

  int _firstWeekday(DateTime m) =>
      DateTime(m.year, m.month, 1).weekday; // Mon=1

  @override
  Widget build(BuildContext context) {
    final year = _displayed.year;
    final month = _displayed.month;
    final days = _daysInMonth(_displayed);
    final leading = _firstWeekday(_displayed) - 1; // spaces before day 1

    final List<Widget> cells = [];

    // previous month's tail days
    final prevMonthLastDay = DateTime(year, month, 0).day;
    for (int i = 0; i < leading; i++) {
      final day = prevMonthLastDay - (leading - 1) + i;
      cells.add(_dayCell(day, muted: true, onTapDate: null));
    }

    // current month days
    for (int d = 1; d <= days; d++) {
      final date = DateTime(year, month, d);
      final isSelected =
          _selected != null &&
          _selected!.year == date.year &&
          _selected!.month == date.month &&
          _selected!.day == date.day;
      cells.add(
        _dayCell(d, muted: false, isSelected: isSelected, onTapDate: date),
      );
    }

    // next month's leading days to fill the grid
    int remainder = cells.length % 7;
    if (remainder != 0) {
      final toAdd = 7 - remainder;
      for (int i = 1; i <= toAdd; i++) {
        cells.add(_dayCell(i, muted: true, onTapDate: null));
      }
    }

    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // small drag handle to indicate sheet can be dragged
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
              child: Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Text(
                    'Select date',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            // toolbar with month and year nav
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(color: Color(0xFFF3F5F9)),
              child: Row(
                children: [
                  // month nav
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: _prev,
                      ),
                      Text(
                        '${_monthNames[month - 1]}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: _next,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // year nav
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () => setState(
                          () => _displayed = DateTime(
                            _displayed.year - 1,
                            _displayed.month,
                          ),
                        ),
                      ),
                      Text(
                        '$year',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () => setState(
                          () => _displayed = DateTime(
                            _displayed.year + 1,
                            _displayed.month,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Mon', style: TextStyle(color: Colors.black54)),
                  Text('Tue', style: TextStyle(color: Colors.black54)),
                  Text('Wed', style: TextStyle(color: Colors.black54)),
                  Text('Thu', style: TextStyle(color: Colors.black54)),
                  Text('Fri', style: TextStyle(color: Colors.black54)),
                  Text('Sat', style: TextStyle(color: Colors.black54)),
                  Text('Sun', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Calendar grid
            Container(
              color: const Color(0xFFF3F5F9),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: GridView.count(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: cells,
              ),
            ),

            // footer removed — bottom sheet shows only the calendar
          ],
        ),
      ),
    );
  }
}
