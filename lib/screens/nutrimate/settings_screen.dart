import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedUnit = 'Metric';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _locationEnabled = prefs.getBool('locationEnabled') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _selectedUnit = prefs.getString('unit') ?? 'Metric';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('locationEnabled', _locationEnabled);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('unit', _selectedUnit);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Theme.of(context).primaryColor.withOpacity(0.2),
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSection('Appearance', [
              SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                    _saveSettings();
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              ListTile(
                title: Text(
                  'Language',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: _selectedLanguage,
                  items: ['English', 'Hindi', 'Spanish', 'French']
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLanguage = value;
                        _saveSettings();
                      });
                    }
                  },
                ),
              ),
            ]),
            SizedBox(height: 16),
            _buildSection('Preferences', [
              SwitchListTile(
                title: Text(
                  'Notifications',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Receive meal reminders and updates',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                    _saveSettings();
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              SwitchListTile(
                title: Text(
                  'Location Services',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Enable location-based features',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                    _saveSettings();
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              ListTile(
                title: Text(
                  'Units',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: _selectedUnit,
                  items: ['Metric', 'Imperial']
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedUnit = value;
                        _saveSettings();
                      });
                    }
                  },
                ),
              ),
            ]),
            SizedBox(height: 16),
            _buildSection('Account', [
              ListTile(
                leading: Icon(
                  Icons.security,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                title: Text(
                  'Privacy Settings',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.backup,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                title: Text(
                  'Backup & Restore',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                onTap: () {
                  // Navigate to backup settings
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}
