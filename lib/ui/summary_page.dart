import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import '../model/schedule.dart';

class SummaryPage extends StatefulWidget {
  final List<Schedule> schedules;

  const SummaryPage({super.key, required this.schedules});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String? _summary;
  bool _isLoading = true;
  String? _error;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _generateSummary();
    }
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (widget.schedules.isEmpty) {
      setState(() {
        _summary = "You don't have any schedules yet. Add some to get a summary!";
        _isLoading = false;
      });
      return;
    }

    final scheduleText = widget.schedules
        .map((s) => "- ${s.time.format(context)}: ${s.title} (${s.description})")
        .join("\n");

    final prompt = """
Summarize my daily schedule and give me some productivity advice or motivation based on it.
Keep it concise but encouraging.

My schedule:
$scheduleText
""";

    try {
      final response = await Gemini.instance.text(prompt).timeout(const Duration(seconds: 20));

      if (!mounted) return;
      setState(() {
        _summary = response?.output ?? "No response.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Error generating summary: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Deep Purple agar senada dengan dialog
    final primaryColor = Colors.deepPurple;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AI Daily Summary', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    const SizedBox(height: 20),
                    Text('Analyzing your day...', 
                         style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                        TextButton(onPressed: _generateSummary, child: const Text("Try Again"))
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // AI Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: primaryColor.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: primaryColor.withOpacity(0.1),
                                    child: Icon(Icons.auto_awesome, color: primaryColor, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Gemini Insight',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _summary ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Refresh Button
                        ElevatedButton.icon(
                          onPressed: _generateSummary,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Regenerate Summary'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }
}