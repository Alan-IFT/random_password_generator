import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/password_generator.dart';
import 'dart:ui';
import '../utils/responsive_utils.dart';

const _maxContentWidth = 600.0;  // 减小最大宽度，使内容更紧凑
const _cardBackgroundColor = Color(0xFFFFFFFF);  // 使用纯白色背景
const _accentColor = Color(0xFF2196F3);  // 主题色
const _strengthColors = {
  'weak': Color(0xFFFF4D4D),
  'medium': Color(0xFFFFAD33),
  'strong': Color(0xFF00CC66),
  'veryStrong': Color(0xFF00994D),
};

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final PasswordGenerator _passwordGenerator = PasswordGenerator();
  String _generatedPassword = '';
  int _minLength = 8;
  int _maxLength = 16;
  bool _useSpecialChars = true;
  bool _useCaseSensitive = true;
  bool _useNumbers = true;
  int _minSpecialChars = 1;
  int _minNumbers = 1;
  int _minUppercase = 1;
  int _minLowercase = 1;
  PasswordStrength? _passwordStrength;
  bool _useUncommonSpecialChars = false;
  final TextEditingController _minLengthController = TextEditingController();
  final TextEditingController _maxLengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _minLengthController.text = _minLength.toString();
    _maxLengthController.text = _maxLength.toString();
  }

  @override
  void dispose() {
    _minLengthController.dispose();
    _maxLengthController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    setState(() {
      try {
        _generatedPassword = _passwordGenerator.generatePassword(
          minLength: _minLength,
          maxLength: _maxLength,
          useSpecialChars: _useSpecialChars,
          useUncommonSpecialChars: _useUncommonSpecialChars,
          useCaseSensitive: _useCaseSensitive,
          useNumbers: _useNumbers,
          minSpecialChars: _useSpecialChars ? _minSpecialChars : 0,
          minNumbers: _useNumbers ? _minNumbers : 0,
          minUppercase: _useCaseSensitive ? _minUppercase : 0,
          minLowercase: _minLowercase,
        );
        _passwordStrength = _passwordGenerator.checkPasswordStrength(_generatedPassword);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    });
  }

  // 添加新的方法来获取密码强度颜色
  Color _getStrengthColor(double strength) {
    if (strength < 30) return Colors.red;
    if (strength < 60) return Colors.orange;
    if (strength < 80) return Colors.yellow;
    return Colors.green;
  }

  // 在Card中的密码显示部分后添加强度指示器
  Widget _buildStrengthIndicator() {
    if (_generatedPassword.isEmpty || _passwordStrength == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('密码强度: '),
            Expanded(
              child: LinearProgressIndicator(
                value: _passwordStrength!.score / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStrengthColor(_passwordStrength!.score),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${_passwordStrength!.score.toInt()}%'),
          ],
        ),
        if (_passwordStrength!.suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '建议改进：',
            style: TextStyle(color: Colors.grey[600]),
          ),
          ...(_passwordStrength!.suggestions.map((suggestion) => 
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('• $suggestion', style: TextStyle(color: Colors.grey[600])),
            )
          )).toList(),
        ],
      ],
    );
  }

  // 在第二个Card中添加新的控制选项
  Widget _buildAdvancedOptions() {
    return ExpansionTile(
      title: const Text('高级选项'),
      children: [
        if (_useSpecialChars)
          ListTile(
            title: const Text('最少特殊字符数'),
            trailing: DropdownButton<int>(
              value: _minSpecialChars,
              items: List.generate(4, (i) => 
                DropdownMenuItem(value: i, child: Text('$i'))),
              onChanged: (value) => setState(() => _minSpecialChars = value!),
            ),
          ),
        if (_useNumbers)
          ListTile(
            title: const Text('最少数字数'),
            trailing: DropdownButton<int>(
              value: _minNumbers,
              items: List.generate(4, (i) => 
                DropdownMenuItem(value: i, child: Text('$i'))),
              onChanged: (value) => setState(() => _minNumbers = value!),
            ),
          ),
        if (_useCaseSensitive)
          ListTile(
            title: const Text('最少大写字母数'),
            trailing: DropdownButton<int>(
              value: _minUppercase,
              items: List.generate(4, (i) => 
                DropdownMenuItem(value: i, child: Text('$i'))),
              onChanged: (value) => setState(() => _minUppercase = value!),
            ),
          ),
        ListTile(
          title: const Text('最少小写字母数'),
          trailing: DropdownButton<int>(
            value: _minLowercase,
            items: List.generate(4, (i) => 
              DropdownMenuItem(value: i, child: Text('$i'))),
            onChanged: (value) => setState(() => _minLowercase = value!),
          ),
        ),
      ],
    );
  }

  // 在第二个Card中添加特殊字符设置
  Widget _buildSpecialCharsSection() {
    if (!_useSpecialChars) return const SizedBox.shrink();
    
    return Column(
      children: [
        SwitchListTile(
          title: const Text('使用非常用特殊字符'),
          subtitle: Text(
            '当前可用特殊字符: ${_passwordGenerator.getSpecialCharsPreview(
              includeUncommon: _useUncommonSpecialChars
            )}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          value: _useUncommonSpecialChars,
          onChanged: (value) {
            setState(() {
              _useUncommonSpecialChars = value;
            });
          },
        ),
        ListTile(
          title: const Text('最少特殊字符数'),
          trailing: DropdownButton<int>(
            value: _minSpecialChars,
            items: List.generate(4, (i) => 
              DropdownMenuItem(value: i, child: Text('$i'))),
            onChanged: (value) => setState(() => _minSpecialChars = value!),
          ),
        ),
      ],
    );
  }

  // 添加验证和更新方法
  void _updateMinLength(String value) {
    final newValue = int.tryParse(value);
    if (newValue != null && newValue >= 4 && newValue <= 32) {
      setState(() {
        _minLength = newValue;
        if (_maxLength < _minLength) {
          _maxLength = _minLength;
          _maxLengthController.text = _maxLength.toString();
        }
      });
    }
    _minLengthController.text = _minLength.toString();
  }

  void _updateMaxLength(String value) {
    final newValue = int.tryParse(value);
    if (newValue != null && newValue >= 4 && newValue <= 32) {
      setState(() {
        _maxLength = newValue;
        if (_minLength > _maxLength) {
          _minLength = _maxLength;
          _minLengthController.text = _minLength.toString();
        }
      });
    }
    _maxLengthController.text = _maxLength.toString();
  }

  // 修改滑块构建方法
  Widget _buildSlider(String label, int value, TextEditingController controller, ValueChanged<double> onChanged, ValueChanged<String> onSubmitted) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _accentColor,
              inactiveTrackColor: _accentColor.withOpacity(0.1),
              thumbColor: _accentColor,
              overlayColor: _accentColor.withOpacity(0.2),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 4,
              max: 32,
              divisions: 28,
              label: value.toString(),
              onChanged: (newValue) {
                onChanged(newValue);
                controller.text = newValue.toInt().toString();
              },
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            onSubmitted: onSubmitted,
          ),
        ),
      ],
    );
  }

  // 修改长度滑块部分
  Widget _buildLengthSliders() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.straighten, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 12),
              Text(
                '密码长度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_minLength - $_maxLength 字符',
                  style: TextStyle(
                    color: _accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSlider(
            '最小',
            _minLength,
            _minLengthController,
            (value) {
              setState(() {
                _minLength = value.toInt();
                if (_maxLength < _minLength) {
                  _maxLength = _minLength;
                  _maxLengthController.text = _maxLength.toString();
                }
              });
            },
            _updateMinLength,
          ),
          const SizedBox(height: 16),
          _buildSlider(
            '最大',
            _maxLength,
            _maxLengthController,
            (value) {
              setState(() {
                _maxLength = value.toInt();
                if (_minLength > _maxLength) {
                  _minLength = _maxLength;
                  _minLengthController.text = _minLength.toString();
                }
              });
            },
            _updateMaxLength,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '密码选项',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        _buildOptionSwitch(
          '特殊字符',
          '!@#\$%^&*()等',
          _useSpecialChars,
          (value) => setState(() => _useSpecialChars = value),
        ),
        _buildOptionSwitch(
          '区分大小写',
          '包含大写和小写字母',
          _useCaseSensitive,
          (value) => setState(() => _useCaseSensitive = value),
        ),
        _buildOptionSwitch(
          '数字',
          '0-9',
          _useNumbers,
          (value) => setState(() => _useNumbers = value),
        ),
      ],
    );
  }

  Widget _buildOptionSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: _accentColor,
      ),
    );
  }

  Widget _buildAdvancedOptionsSection() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: const Text('高级选项'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                if (_useSpecialChars) _buildSpecialCharsSection(),
                if (_useCaseSensitive)
                  _buildNumberDropdown('最少大写字母数', _minUppercase, 
                    (value) => setState(() => _minUppercase = value)),
                _buildNumberDropdown('最少小写字母数', _minLowercase,
                  (value) => setState(() => _minLowercase = value)),
                if (_useNumbers)
                  _buildNumberDropdown('最少数字数', _minNumbers,
                    (value) => setState(() => _minNumbers = value)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberDropdown(String title, int value, ValueChanged<int> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<int>(
        value: value,
        items: List.generate(4, (i) => 
          DropdownMenuItem(value: i, child: Text('$i'))),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  Widget _buildGenerateButton() {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return SizedBox(
      width: double.infinity,
      height: isDesktop ? 48 : 44,
      child: ElevatedButton.icon(
        onPressed: _generatePassword,
        icon: const Icon(Icons.refresh),
        label: const Text('生成密码'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: deviceType == DeviceType.desktop ? 16 : 14),
        ),
        behavior: SnackBarBehavior.floating,
        width: ResponsiveUtils.getContentMaxWidth(deviceType) * 0.8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    final maxWidth = ResponsiveUtils.getContentMaxWidth(deviceType);
    final padding = ResponsiveUtils.getContentPadding(deviceType);
    final isDesktop = deviceType == DeviceType.desktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('密码生成器'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24.0 : 16.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPasswordCard(),
                        const SizedBox(height: 16),
                        _buildGenerateButton(),
                        const SizedBox(height: 16),
                        _buildSettingsCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _generatedPassword.isEmpty ? '点击下方按钮生成密码' : _generatedPassword,
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 18,
                        color: _generatedPassword.isEmpty ? 
                          Colors.grey[400] : Colors.grey[800],
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_generatedPassword.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedPassword));
                        _showSnackBar('密码已复制到剪贴板');
                      },
                      tooltip: '复制密码',
                      style: IconButton.styleFrom(
                        backgroundColor: _accentColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_passwordStrength != null) ...[
              const SizedBox(height: 16),
              _buildStrengthIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLengthSliders(),
                const Divider(height: 32),
                _buildOptionsSection(),
              ],
            ),
          ),
          _buildAdvancedOptionsSection(),
        ],
      ),
    );
  }
} 