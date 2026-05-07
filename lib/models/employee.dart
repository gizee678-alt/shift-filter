class Employee {
  final String name;
  final Map<String, String> shifts; // day -> shift value

  const Employee({
    required this.name,
    required this.shifts,
  });

  String? shiftFor(String day) => shifts[day];

  bool hasShift(String shift) => shifts.values.contains(shift);

  List<String> get workedDays => shifts.keys.toList();

  @override
  String toString() => 'Employee($name, $shifts)';
}

class RosterData {
  final List<Employee> employees;
  final List<String> days;
  final DateTime parsedAt;
  final String? imagePath;

  const RosterData({
    required this.employees,
    required this.days,
    required this.parsedAt,
    this.imagePath,
  });

  int get totalEmployees => employees.length;

  List<Employee> filterByDayAndShift(String? day, String? shift) {
    return employees.where((e) {
      if (day != null && shift != null) {
        return e.shifts[day] == shift;
      } else if (day != null) {
        return e.shifts.containsKey(day);
      } else if (shift != null) {
        return e.hasShift(shift);
      }
      return true;
    }).toList();
  }

  List<Employee> searchByName(List<Employee> source, String query) {
    if (query.isEmpty) return source;
    final q = query.toLowerCase();
    return source.where((e) => e.name.toLowerCase().contains(q)).toList();
  }
}

const List<String> kSupportedShifts = [
  '0730-1730',
  '1230-2230',
  '2200-0800',
  'RDO',
];

const List<String> kAllDays = [
  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  '1', '2', '3', '4', '5', '6', '7', '8', '9', '10',
  '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',
  '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31',
];
