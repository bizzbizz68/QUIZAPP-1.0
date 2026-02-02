import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/models/question_model.dart';
import '../../data/sources/hierarchical_question_bank_service.dart';
import '../../../../core/services/file_upload_service.dart';
import '../../utils/question_type_helper.dart';
import '../../utils/hsk_structure.dart';

/// Add/Edit Question Screen - Thêm/Sửa câu hỏi
class AddEditQuestionScreen extends StatefulWidget {
  final QuestionModel? question; // null = add new
  final int? hskLevel; // Pre-select level

  const AddEditQuestionScreen({
    super.key,
    this.question,
    this.hskLevel,
  });

  @override
  State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionBankService = HierarchicalQuestionBankService();
  final _fileUploadService = FileUploadService();

  // Controllers
  late TextEditingController _contentController;
  late TextEditingController _correctAnswerController;
  late TextEditingController _explanationController;
  late TextEditingController _tagsController;

  // Form values
  late int _selectedLevel;
  String _selectedSection = 'nghe';
  QuestionType _selectedType = QuestionType.nghe_dung_sai;
  String _selectedRangeGroup = '1-5';
  String? _selectedDifficulty;
  
  // Option controllers
  List<TextEditingController> _optionControllers = [];

  // File uploads
  String? _audioUrl;
  String? _imageUrl;
  List<String> _imageUrls = []; // For multiple images (A, B, C...)
  String? _audioFileName;
  String? _imageFileName;
  bool _isUploadingAudio = false;
  bool _isUploadingImage = false;

  bool _isSaving = false;

  // Get current question type requirement
  QuestionTypeRequirement get _requirement =>
      QuestionTypeHelper.getRequirement(_selectedType);

  @override
  void initState() {
    super.initState();

    if (widget.question != null) {
      // Edit mode
      final q = widget.question!;
      _selectedLevel = q.hskLevel;
      _selectedSection = q.section;
      _selectedType = q.type;
      _selectedRangeGroup = '1-50'; // TODO: Add rangeGroup to QuestionModel
      _selectedDifficulty = 'medium'; // TODO: Add difficulty to QuestionModel

      _contentController = TextEditingController(text: (q.content['text'] ?? '').toString());
      _correctAnswerController = TextEditingController(
        text: q.correctAnswer?.toString() ?? '',
      );
      _explanationController = TextEditingController(text: q.explanation ?? '');
      _tagsController = TextEditingController(text: ''); // TODO: Add tags to QuestionModel

      _audioUrl = q.content['audioUrl']?.toString();
      _imageUrl = q.content['imageUrl']?.toString();

      // Load options
      for (var option in q.options) {
        _optionControllers.add(TextEditingController(text: option));
      }

      // Ensure at least 2 options
      if (_optionControllers.length < 2) {
        for (int i = _optionControllers.length; i < 2; i++) {
          _optionControllers.add(TextEditingController());
        }
      }
    } else {
      // Add new mode
      _selectedLevel = widget.hskLevel ?? 1;
      _contentController = TextEditingController();
      _correctAnswerController = TextEditingController();
      _explanationController = TextEditingController();
      _tagsController = TextEditingController();

      // Default options based on type
      _updateOptionsForType();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _correctAnswerController.dispose();
    _explanationController.dispose();
    _tagsController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateOptionsForType() {
    // Clear existing
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _optionControllers.clear();

    // Use helper to get requirements
    final req = QuestionTypeHelper.getRequirement(_selectedType);
    
    // Auto-update section based on question type
    _selectedSection = QuestionTypeHelper.getSection(_selectedType);
    
    // Auto-update range group from HSK structure
    final rangeOptions = HskStructure.getRangeOptions(_selectedLevel, _selectedType);
    if (rangeOptions.isNotEmpty) {
      _selectedRangeGroup = rangeOptions.first;
    }
    
    // Add options based on requirement
    for (var label in req.optionsLabels) {
      _optionControllers.add(TextEditingController(text: label));
    }

    setState(() {});
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickAndUploadAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _isUploadingAudio = true;
          _audioFileName = result.files.single.name;
        });

        final url = await _fileUploadService.uploadAudio(
          fileBytes: result.files.single.bytes!,
          fileName: result.files.single.name,
          hskLevel: _selectedLevel,
          questionType: _selectedType.toString().split('.').last,
        );

        setState(() {
          _audioUrl = url;
          _isUploadingAudio = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Upload audio thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingAudio = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi upload audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _isUploadingImage = true;
          _imageFileName = result.files.single.name;
        });

        final url = await _fileUploadService.uploadImage(
          fileBytes: result.files.single.bytes!,
          fileName: result.files.single.name,
          hskLevel: _selectedLevel,
          questionType: _selectedType.toString().split('.').last,
        );

        setState(() {
          _imageUrl = url;
          _isUploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Upload hình ảnh thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi upload image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate requirements
    if (_requirement.requiresAudio && (_audioUrl == null || _audioUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Loại câu hỏi này yêu cầu upload audio!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_requirement.requiresImage && (_imageUrl == null || _imageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Loại câu hỏi này yêu cầu upload hình ảnh!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Build content map
      final content = <String, dynamic>{
        'text': _contentController.text.trim(),
      };
      if (_audioUrl != null && _audioUrl!.isNotEmpty) {
        content['audioUrl'] = _audioUrl;
      }
      if (_imageUrl != null && _imageUrl!.isNotEmpty) {
        content['imageUrl'] = _imageUrl;
      }

      // Get options
      final options = _optionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (widget.question == null) {
        // Add new
        await _questionBankService.addQuestion(
          hskLevel: _selectedLevel,
          section: _selectedSection,
          questionType: _selectedType,
          content: content,
          options: options,
          correctAnswer: _correctAnswerController.text.trim(),
          explanation: _explanationController.text.trim().isEmpty
              ? null
              : _explanationController.text.trim(),
          createdBy: 'admin', // TODO: Get current user
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Thêm câu hỏi thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Update
        await _questionBankService.updateQuestion(
          hskLevel: widget.question!.hskLevel,
          section: widget.question!.section,
          questionType: widget.question!.type,
          questionId: widget.question!.id,
          updates: {
            'content': content,
            'options': options,
            'correctAnswer': _correctAnswerController.text.trim(),
            'explanation': _explanationController.text.trim().isEmpty
                ? null
                : _explanationController.text.trim(),
            'difficulty': _selectedDifficulty,
            'tags': tags,
            'updatedBy': 'admin', // TODO: Get current user
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Cập nhật câu hỏi thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.question != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh Sửa Câu Hỏi' : 'Thêm Câu Hỏi Mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // HSK Level
            DropdownButtonFormField<int>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Cấp độ HSK *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
                helperText: '1️⃣ Chọn cấp độ HSK trước',
              ),
              items: List.generate(6, (i) => i + 1)
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text('HSK $level'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                  
                  // Check if current type exists in new level
                  final newLevelTypes = HskStructure.getQuestionTypes(
                    _selectedLevel,
                    _selectedSection,
                  );
                  
                  if (!newLevelTypes.contains(_selectedType)) {
                    // Type doesn't exist in new level - select first one
                    if (newLevelTypes.isNotEmpty) {
                      _selectedType = newLevelTypes.first;
                    }
                  }
                  
                  // Auto-update range group
                  final rangeOptions = HskStructure.getRangeOptions(
                    _selectedLevel,
                    _selectedType,
                  );
                  if (rangeOptions.isNotEmpty) {
                    _selectedRangeGroup = rangeOptions.first;
                  }
                  
                  _updateOptionsForType();
                });
              },
            ),
            const SizedBox(height: 16),

            // Section
            DropdownButtonFormField<String>(
              value: _selectedSection,
              decoration: const InputDecoration(
                labelText: 'Phần *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
                helperText: '2️⃣ Chọn phần thi (Nghe/Đọc/Viết)',
              ),
              items: const [
                DropdownMenuItem(value: 'nghe', child: Text('Nghe')),
                DropdownMenuItem(value: 'doc', child: Text('Đọc')),
                DropdownMenuItem(value: 'viet', child: Text('Viết')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSection = value!;
                  
                  // Get types for new section from HSK structure
                  final sectionTypes = HskStructure.getQuestionTypes(
                    _selectedLevel,
                    _selectedSection,
                  );
                  
                  // Auto-select first type for this section
                  if (sectionTypes.isNotEmpty) {
                    if (!sectionTypes.contains(_selectedType)) {
                      _selectedType = sectionTypes.first;
                    }
                  }
                  
                  _updateOptionsForType();
                });
              },
            ),
            const SizedBox(height: 16),

            // Question Type (from HSK structure - in correct order)
            Builder(
              builder: (context) {
                // Get types from HSK structure (in correct order!)
                final orderedTypes = HskStructure.getQuestionTypes(
                  _selectedLevel,
                  _selectedSection,
                );

                // Ensure selected type is in list
                if (!orderedTypes.contains(_selectedType)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (orderedTypes.isNotEmpty) {
                      setState(() {
                        _selectedType = orderedTypes.first;
                        _updateOptionsForType();
                      });
                    }
                  });
                }

                return DropdownButtonFormField<QuestionType>(
                  value: orderedTypes.contains(_selectedType) 
                      ? _selectedType 
                      : (orderedTypes.isNotEmpty ? orderedTypes.first : QuestionType.nghe_dung_sai),
                  decoration: const InputDecoration(
                    labelText: 'Loại câu hỏi *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.quiz),
                    helperText: '3️⃣ Chọn loại câu hỏi (theo thứ tự cấu trúc HSK)',
                  ),
                  isExpanded: true,
                  items: orderedTypes
                      .map((type) {
                        // Get description from structure
                        final structureItems = HskStructure.getStructure(_selectedLevel)
                            .where((item) => item.type == type)
                            .toList();
                        
                        final desc = structureItems.isNotEmpty 
                            ? structureItems.first.description 
                            : type.toString().split('.').last.replaceAll('_', ' ');

                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            desc,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      _updateOptionsForType();
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // Range Group (from HSK structure)
            Builder(
              builder: (context) {
                // Get range options from HSK structure
                final rangeOptions = HskStructure.getRangeOptions(
                  _selectedLevel,
                  _selectedType,
                );

                if (rangeOptions.isEmpty) {
                  // No structure defined - manual input
                  return TextFormField(
                    initialValue: _selectedRangeGroup,
                    decoration: const InputDecoration(
                      labelText: 'Nhóm câu *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                      helperText: 'Nhập thủ công (loại này chưa có trong cấu trúc HSK)',
                    ),
                    onChanged: (value) => _selectedRangeGroup = value,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập nhóm câu';
                      }
                      return null;
                    },
                  );
                } else if (rangeOptions.length == 1) {
                  // Single range - auto-fill (read-only)
                  if (_selectedRangeGroup != rangeOptions.first) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => _selectedRangeGroup = rangeOptions.first);
                    });
                  }
                  return TextFormField(
                    initialValue: rangeOptions.first,
                    decoration: InputDecoration(
                      labelText: 'Nhóm câu *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.numbers),
                      helperText: '4️⃣ Tự động điền theo cấu trúc HSK',
                      fillColor: Colors.grey[100],
                      filled: true,
                    ),
                    readOnly: true,
                  );
                } else {
                  // Multiple ranges - dropdown
                  if (!rangeOptions.contains(_selectedRangeGroup)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => _selectedRangeGroup = rangeOptions.first);
                    });
                  }
                  return DropdownButtonFormField<String>(
                    value: rangeOptions.contains(_selectedRangeGroup)
                        ? _selectedRangeGroup
                        : rangeOptions.first,
                    decoration: const InputDecoration(
                      labelText: 'Nhóm câu *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                      helperText: '4️⃣ Chọn nhóm câu theo cấu trúc HSK',
                    ),
                    items: rangeOptions
                        .map((range) => DropdownMenuItem(
                              value: range,
                              child: Text('Câu $range'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedRangeGroup = value ?? rangeOptions.first);
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Question Type Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _requirement.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_requirement.helpText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _requirement.helpText!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Audio Upload (conditional)
            if (_requirement.requiresAudio) ...[
              Row(
                children: [
                  const Text(
                    '🎧 Audio',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BẮT BUỘC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploadingAudio ? null : _pickAndUploadAudio,
                  icon: _isUploadingAudio
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(_isUploadingAudio ? 'Đang upload...' : 'Chọn file audio'),
                ),
                const SizedBox(width: 16),
                if (_audioUrl != null)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _audioFileName ?? 'Audio đã upload',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => setState(() {
                            _audioUrl = null;
                            _audioFileName = null;
                          }),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
              const SizedBox(height: 16),
            ],

            // Image Upload (conditional)
            if (_requirement.requiresImage) ...[
              Row(
                children: [
                  const Text(
                    '🖼️ Hình ảnh',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BẮT BUỘC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                  icon: _isUploadingImage
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(_isUploadingImage ? 'Đang upload...' : 'Chọn hình ảnh'),
                ),
                const SizedBox(width: 16),
                if (_imageUrl != null)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _imageFileName ?? 'Hình đã upload',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => setState(() {
                            _imageUrl = null;
                            _imageFileName = null;
                          }),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Content Text (conditional)
            if (_requirement.requiresText) ...[
              Row(
                children: [
                  const Text(
                    '📝 Nội dung câu hỏi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BẮT BUỘC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung text',
                  hintText: 'Nhập nội dung câu hỏi...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                maxLines: 4,
                validator: (value) {
                  if (_requirement.requiresText &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Vui lòng nhập nội dung câu hỏi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Options Section
            const Text(
              '✅ Các đáp án:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Display options based on type
            if (_requirement.optionsType == OptionsType.trueFalse) ...[
              // For True/False, show fixed labels
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Đúng', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 32),
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sai', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ] else if (_requirement.optionsType == OptionsType.images) ...[
              // For image options, show labels
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: _requirement.optionsLabels.map((label) {
                    return Chip(
                      label: Text(label),
                      backgroundColor: Colors.blue[100],
                    );
                  }).toList(),
                ),
              ),
            ] else ...[
              // For text options, allow editing
              ..._optionControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          _requirement.optionsLabels[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Đáp án ${_requirement.optionsLabels[index]}',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập đáp án';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),

            // Correct Answer (Dropdown for fixed options)
            if (_requirement.optionsType == OptionsType.trueFalse ||
                _requirement.optionsType == OptionsType.images) ...[
              DropdownButtonFormField<String>(
                value: _correctAnswerController.text.isEmpty
                    ? null
                    : _correctAnswerController.text,
                decoration: const InputDecoration(
                  labelText: 'Đáp án đúng *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle, color: Colors.green),
                ),
                items: _requirement.optionsLabels
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _correctAnswerController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn đáp án đúng';
                  }
                  return null;
                },
              ),
            ] else ...[
              // Text field for text options
              TextFormField(
                controller: _correctAnswerController,
                decoration: InputDecoration(
                  labelText: 'Đáp án đúng *',
                  hintText: 'Nhập ${_requirement.optionsLabels.join(", ")}',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.check_circle, color: Colors.green),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập đáp án đúng';
                  }
                  if (!_requirement.optionsLabels.contains(value.trim())) {
                    return 'Đáp án phải là một trong: ${_requirement.optionsLabels.join(", ")}';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),

            // Explanation
            TextFormField(
              controller: _explanationController,
              decoration: const InputDecoration(
                labelText: 'Giải thích (tùy chọn)',
                hintText: 'Giải thích đáp án...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Tags (with explanation)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Tags là gì?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tags giúp phân loại câu hỏi theo chủ đề (VD: greeting, family, food, numbers). '
                  'Dùng để tìm kiếm và lọc câu hỏi dễ dàng hơn.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (tùy chọn)',
                    hintText: 'greeting, numbers, food (cách nhau bằng dấu phẩy)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                    helperText: 'VD: greeting, basic, numbers',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveQuestion,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving
                  ? 'Đang lưu...'
                  : (isEdit ? 'Cập Nhật' : 'Thêm Câu Hỏi')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
