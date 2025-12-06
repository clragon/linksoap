import 'package:flutter/material.dart';
import 'package:linksoap/core/washer.dart';
import 'package:linksoap/detergent/model.dart';

class DetergentEditorScreen extends StatefulWidget {
  final Detergent? detergent;

  const DetergentEditorScreen({super.key, this.detergent});

  @override
  State<DetergentEditorScreen> createState() => _DetergentEditorScreenState();
}

class _DetergentEditorScreenState extends State<DetergentEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _domainController;
  late TextEditingController _ruleController;
  late TextEditingController _testUrlController;

  String _testResult = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.detergent?.name ?? '');
    _domainController =
        TextEditingController(text: widget.detergent?.domain ?? '');
    _ruleController = TextEditingController(text: widget.detergent?.rule ?? '');
    _testUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _domainController.dispose();
    _ruleController.dispose();
    _testUrlController.dispose();
    super.dispose();
  }

  void _testDetergent() {
    setState(() {
      _errorMessage = null;
      if (_testUrlController.text.isEmpty) {
        _testResult = '';
        return;
      }

      try {
        final testDetergent = Detergent(
          name: _nameController.text.isEmpty ? 'Test' : _nameController.text,
          domain: _domainController.text,
          rule: _ruleController.text,
        );

        final washer = Washer(
          softeners: const [],
          detergents: [testDetergent],
        );

        _testResult = washer.wash(_testUrlController.text);
      } catch (e) {
        _errorMessage = e.toString();
        _testResult = '';
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final detergent = Detergent(
      name: _nameController.text.trim(),
      domain: _domainController.text.trim(),
      rule: _ruleController.text.trim(),
    );

    Navigator.pop(context, detergent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.detergent == null ? 'New Detergent' : 'Edit Detergent'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Icon(Icons.cleaning_services, size: 48),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., Default',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _domainController,
                decoration: const InputDecoration(
                  labelText: 'Domain Pattern (regex)',
                  hintText: r'e.g., .* (matches all)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Domain pattern is required';
                  }
                  try {
                    RegExp(value.trim());
                  } catch (e) {
                    return 'Invalid regex pattern';
                  }
                  return null;
                },
                onChanged: (_) => _testDetergent(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ruleController,
                decoration: const InputDecoration(
                  labelText: 'Query Parameters to Remove (regex)',
                  hintText: r'e.g., utm|ref|source',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Rule is required';
                  }
                  try {
                    RegExp(value.trim());
                  } catch (e) {
                    return 'Invalid regex pattern';
                  }
                  return null;
                },
                onChanged: (_) => _testDetergent(),
              ),
              const SizedBox(height: 32),
              Text(
                'Test',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _testUrlController,
                decoration: InputDecoration(
                  labelText: 'Test URL',
                  hintText: 'https://example.com?utm_source=test&id=123',
                  border: const OutlineInputBorder(),
                  suffixIcon: _testUrlController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _testUrlController.clear();
                              _testResult = '';
                              _errorMessage = null;
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (_) => _testDetergent(),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              if (_testResult.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Result:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (_testResult != _testUrlController.text) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _testResult,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: _testResult == _testUrlController.text
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
