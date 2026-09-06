import 'package:DengueLens/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EducationalLibraryScreen extends StatelessWidget {
  const EducationalLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          loc.educationalLibrary,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'manual_educational_library',
        onPressed: () {
          // TODO: Implement user manual navigation
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.menu_book, color: Color(0xFF2ECC71)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle(loc.mosquitoSpecies),
          _buildCard(
            title: loc.aedesAegyptiTitle,
            content: loc.aedesAegyptiDesc,
            icon: Icons.bug_report,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: loc.aedesAlbopictusTitle,
            content: loc.aedesAlbopictusDesc,
            icon: Icons.bug_report_outlined,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: loc.culexTitle,
            content: loc.culexDesc,
            icon: Icons.bug_report_outlined,
            color: Colors.brown,
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: loc.anophelesTitle,
            content: loc.anophelesDesc,
            icon: Icons.bug_report_outlined,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(loc.dengueSymptoms),
          _buildCard(
            title: loc.commonSymptomsTitle,
            content: loc.commonSymptomsDesc,
            icon: Icons.sick,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: loc.severeDengueTitle,
            content: loc.severeDengueDesc,
            icon: Icons.warning,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(loc.preventionGuidelines),
          _buildCard(
            title: loc.preventBitesTitle,
            content: loc.preventBitesDesc,
            icon: Icons.health_and_safety,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: loc.eliminateSitesTitle,
            content: loc.eliminateSitesDesc,
            icon: Icons.cleaning_services,
            color: Colors.teal,
          ),
          const SizedBox(height: 32),
          _buildSectionTitle(loc.about),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              loc.aboutDesc,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
