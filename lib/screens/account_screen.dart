import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isColorToggleActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            // Profile section
            _buildProfileSection(),
            const SizedBox(height: 32),
            
            // User details
            _buildUserDetails(),
            const SizedBox(height: 32),
            
            // Personalization section
            _buildPersonalizationSection(),
            const SizedBox(height: 32),
            
            // Security section
            _buildSecuritySection(),
            const SizedBox(height: 32),
            
            // Other section
            _buildOtherSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ahoj, Kristína',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Zozbieraných 568€',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF5E18EA),
          ),
        ),
      ],
    );
  }
  
  Widget _buildUserDetails() {
    final details = [
      _DetailItem(icon: '👤', text: 'Kristína Špirengová'),
      _DetailItem(icon: '📞', text: '+421 123 456 789'),
      _DetailItem(icon: '✉️', text: 'spajrengova@gmail.com'),
      _DetailItem(icon: '💳', text: 'SK12 3456 7890 1234 5678 9012'),
      _DetailItem(icon: '📍', text: 'Slovensko'),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...details.map((detail) => _buildDetailItem(detail)),
      ],
    );
  }
  
  Widget _buildDetailItem(_DetailItem detail) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFD9D9D9)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                detail.icon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 12),
              Text(
                detail.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Text(
            'Upraviť',
            style: TextStyle(
              color: Color(0xFF5E18EA),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPersonalizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personalizácia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        // Color toggle
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFD9D9D9)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Farba',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isColorToggleActive = !_isColorToggleActive;
                  });
                },
                child: Container(
                  width: 50,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _isColorToggleActive 
                        ? const Color(0xFF5E18EA)
                        : const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: _isColorToggleActive 
                        ? Alignment.centerRight 
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Language
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jazyk',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const Text(
                'Slovenčina',
                style: TextStyle(
                  color: Color(0xFF5E18EA),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bezpečnosť',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        // Password
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFD9D9D9)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text(
                    '🔒',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Heslo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Text(
                'Upraviť',
                style: TextStyle(
                  color: Color(0xFF5E18EA),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Privacy
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: const Row(
            children: [
              Text(
                '👁️‍🗨️',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(width: 12),
              Text(
                'Súkromie',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOtherSection() {
    final otherItems = [
      _OtherItem(text: 'ℹ️ Zistiť viac', isDanger: false),
      _OtherItem(text: '🚪 Odhlásiť sa', isDanger: false),
      _OtherItem(text: '👤❌ Zmazať účet', isDanger: true),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Iné',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        
        ...otherItems.map((item) => _buildOtherItem(item)),
      ],
    );
  }
  
  Widget _buildOtherItem(_OtherItem item) {
    return GestureDetector(
      onTap: () => _handleOtherItemTap(item),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFD9D9D9)),
          ),
        ),
        child: Text(
          item.text,
          style: TextStyle(
            color: item.isDanger ? const Color(0xFFEF4444) : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  
  void _handleOtherItemTap(_OtherItem item) {
    if (item.text.contains('Odhlásiť sa')) {
      _showLogoutDialog();
    } else if (item.text.contains('Zmazať účet')) {
      _showDeleteAccountDialog();
    } else {
      // TODO: Implementovať ostatné funkcie
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funkcia bude implementovaná v ďalšej verzii'),
          backgroundColor: Color(0xFF5E18EA),
        ),
      );
    }
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Odhlásiť sa',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Naozaj sa chceš odhlásiť?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Zrušiť',
              style: TextStyle(color: Color(0xFF5E18EA)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementovať odhlásenie
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funkcia odhlásenia bude implementovaná v ďalšej verzii'),
                  backgroundColor: Color(0xFF5E18EA),
                ),
              );
            },
            child: const Text(
              'Odhlásiť',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Zmazať účet',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Naozaj chceš zmazať účet? Táto akcia je nevratná!',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Zrušiť',
              style: TextStyle(color: Color(0xFF5E18EA)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementovať mazanie účtu
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funkcia mazania účtu bude implementovaná v ďalšej verzii'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            child: const Text(
              'Zmazať',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String icon;
  final String text;
  
  _DetailItem({required this.icon, required this.text});
}

class _OtherItem {
  final String text;
  final bool isDanger;
  
  _OtherItem({required this.text, required this.isDanger});
}
