import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ps_institute/config/palette.dart';
import 'package:ps_institute/core/utils/formatters.dart';
import 'package:ps_institute/core/widgets/app_card.dart';
import 'package:ps_institute/data/models/notes_model.dart';

class NotesTile extends StatelessWidget {
  final NotesModel note;

  const NotesTile({
    super.key,
    required this.note,
  });

  // -------------------------------------------------
  // SAFE OPEN FILE (VIEW)
  // -------------------------------------------------
  Future<void> _openFile(BuildContext context) async {
    if (note.fileUrl.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file attached")),
      );
      return;
    }

    final uri = Uri.parse(note.fileUrl);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!context.mounted) return;

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open file")),
      );
    }
  }

  // -------------------------------------------------
  // DOWNLOAD FILE
  // -------------------------------------------------
  Future<void> _downloadFile(BuildContext context) async {
    if (note.fileUrl.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file to download")),
      );
      return;
    }

    final uri = Uri.parse(note.fileUrl);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!context.mounted) return;

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= HEADER =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Palette.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  size: 28,
                  color: Palette.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.subject,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Uploaded: ${Formatters.formatDate(note.uploadedAt)}",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ================= ACTION BUTTONS =================
          if (note.fileUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _openFile(context),
                  icon: const Icon(Icons.visibility),
                  label: const Text("View"),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => _downloadFile(context),
                  icon: const Icon(Icons.download),
                  label: const Text("Download"),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
