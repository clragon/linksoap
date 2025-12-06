import 'package:flutter/material.dart';
import 'package:linksoap/core/washer.dart';
import 'package:linksoap/softener/model.dart';

class SoftenerEditorScreen extends StatefulWidget {
  final Softener? softener;

  const SoftenerEditorScreen({super.key, this.softener});

  @override
  State<SoftenerEditorScreen> createState() => _SoftenerEditorScreenState();
}

class _SoftenerEditorScreenState extends State<SoftenerEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _domainController;
  late TextEditingController _replacementController;
  late TextEditingController _testUrlController;

  String _testResult = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.softener?.name ?? '');
    _domainController =
        TextEditingController(text: widget.softener?.domain ?? '');
    _replacementController =
        TextEditingController(text: widget.softener?.replacement ?? '');
    _testUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _domainController.dispose();
    _replacementController.dispose();
    _testUrlController.dispose();
    super.dispose();
  }

  void _testSoftener() {
    setState(() {
      _errorMessage = null;
      if (_testUrlController.text.isEmpty) {
        _testResult = '';
        return;
      }

      try {
        final testSoftener = Softener(
          name: _nameController.text.isEmpty ? 'Test' : _nameController.text,
          domain: _domainController.text,
          replacement: _replacementController.text,
        );

        final washer = Washer(
          softeners: [testSoftener],
          detergents: const [],
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

    final softener = Softener(
      name: _nameController.text.trim(),
      domain: _domainController.text.trim(),
      replacement: _replacementController.text.trim(),
    );

    Navigator.pop(context, softener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.softener == null ? 'New Softener' : 'Edit Softener'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Icon(Icons.auto_fix_high, size: 48),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., Fix Twitter',
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
                    hintText: r'e.g., twitter\.com|x\.com',
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
                  onChanged: (_) => _testSoftener(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _replacementController,
                  decoration: const InputDecoration(
                    labelText: 'Replacement',
                    hintText: 'e.g., fxtwitter.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Replacement is required';
                    }
                    return null;
                  },
                  onChanged: (_) => _testSoftener(),
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
                    hintText: 'https://twitter.com/user/status/123',
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
                  onChanged: (_) => _testSoftener(),
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
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
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
      ),
    );
  }
}
