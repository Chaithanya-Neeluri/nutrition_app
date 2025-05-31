import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {
  final Function(String) onGenderSelected;
  final String? initialGender;

  const GenderSelector({
    super.key,
    required this.onGenderSelected,
    this.initialGender,
  });

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  String _selectedGender='';

  final List<Map<String, dynamic>> _genders = [
    {'label': 'Male', 'icon': Icons.male},
    {'label': 'Female', 'icon': Icons.female},
    {'label': 'Other', 'icon': Icons.transgender},
  ];

  @override
  void initState() {
    super.initState();
  
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _genders.map((gender) {
            final isSelected = _selectedGender == gender['label'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = gender['label'];
                });
                widget.onGenderSelected(_selectedGender!);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                width:53,
                decoration: BoxDecoration(
                  color: isDarkMode? isSelected ? Colors.lightGreen[100] :const Color.fromARGB(255, 35, 40, 44) :isSelected?Colors.lightGreen:Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode? isSelected ? Colors.green : Colors.white : isSelected ?Colors.green:Colors.grey.shade400,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      gender['icon'],
                      color: isDarkMode? isSelected ? Colors.green : Colors.white  : isSelected ? Colors.green : Colors.black54,
                      size: 14,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      gender['label'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDarkMode?  isSelected ? Colors.green[800] : Colors.white   : isSelected ? Colors.green[800] : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
