import 'dart:math';

class PasswordGenerator {
  static const String _lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numberChars = '0123456789';
  
  // 简化特殊字符集定义
  static const String _commonSpecialChars = '!@#\$%^&*()-_+=';
  static const String _uncommonSpecialChars = '`~[]{}|;:,.<>?/';

  final Random _random = Random.secure();

  String generatePassword({
    required int minLength,
    required int maxLength,
    required bool useSpecialChars,
    required bool useUncommonSpecialChars, // 新增：是否使用非常用特殊字符
    required bool useCaseSensitive,
    required bool useNumbers,
    required int minSpecialChars,
    required int minNumbers,
    required int minUppercase,
    required int minLowercase,
  }) {
    if (minLength < (minSpecialChars + minNumbers + minUppercase + minLowercase)) {
      throw ArgumentError('最小长度不能小于所有必需字符的总和');
    }

    List<String> requiredChars = [];
    String chars = '';
    String specialChars = '';
    
    // 设置特殊字符集
    if (useSpecialChars) {
      specialChars = _commonSpecialChars;
      if (useUncommonSpecialChars) {
        specialChars += _uncommonSpecialChars;
      }
    }
    
    // 添加必需的小写字母
    chars += _lowercaseChars;
    requiredChars.addAll(List.generate(minLowercase, 
      (_) => _lowercaseChars[_random.nextInt(_lowercaseChars.length)]));

    // 添加必需的大写字母
    if (useCaseSensitive) {
      chars += _uppercaseChars;
      requiredChars.addAll(List.generate(minUppercase, 
        (_) => _uppercaseChars[_random.nextInt(_uppercaseChars.length)]));
    }

    // 添加必需的数字
    if (useNumbers) {
      chars += _numberChars;
      requiredChars.addAll(List.generate(minNumbers, 
        (_) => _numberChars[_random.nextInt(_numberChars.length)]));
    }

    // 添加必需的特殊字符
    if (useSpecialChars && specialChars.isNotEmpty) {
      chars += specialChars;
      requiredChars.addAll(List.generate(minSpecialChars, 
        (_) => specialChars[_random.nextInt(specialChars.length)]));
    }

    // 计算剩余需要生成的字符数
    int length = minLength + _random.nextInt(maxLength - minLength + 1);
    int remainingLength = length - requiredChars.length;

    // 生成剩余的随机字符
    if (remainingLength > 0) {
      requiredChars.addAll(List.generate(remainingLength, 
        (_) => chars[_random.nextInt(chars.length)]));
    }

    // 打乱字符顺序
    requiredChars.shuffle(_random);
    return requiredChars.join();
  }

  // 修改密码强度检查方法以支持新的特殊字符集
  PasswordStrength checkPasswordStrength(String password) {
    double score = 0;
    
    // 简化正则表达式
    final commonSpecialPattern = RegExp('[!@#\$%^&*()\\-_+=]');
    final uncommonSpecialPattern = RegExp('[`~\\[\\]{}|;:,.<>?/]');
    
    Map<String, int> counts = {
      'length': password.length,
      'uppercase': password.replaceAll(RegExp('[^A-Z]'), '').length,
      'lowercase': password.replaceAll(RegExp('[^a-z]'), '').length,
      'numbers': password.replaceAll(RegExp('[^0-9]'), '').length,
      'commonSpecial': password.replaceAll(RegExp('[^!@#\$%^&*()\\-_+=]'), '').length,
      'uncommonSpecial': password.replaceAll(RegExp('[^`~\\[\\]{}|;:,.<>?/]'), '').length,
    };

    // 基础分数：长度
    score += counts['length']! * 4;

    // 字符类型加分
    if (counts['uppercase']! > 0) score += 10;
    if (counts['lowercase']! > 0) score += 10;
    if (counts['numbers']! > 0) score += 10;
    if (counts['commonSpecial']! > 0) score += 12;
    if (counts['uncommonSpecial']! > 0) score += 15;

    // 字符数量加分
    score += (counts['uppercase']! + counts['lowercase']! + 
              counts['numbers']! + counts['commonSpecial']! + 
              counts['uncommonSpecial']! * 1.5) * 2;

    // 额外规则
    if (counts['uppercase']! > 0 && counts['lowercase']! > 0) score += 10;
    if (RegExp(r'[a-zA-Z]').hasMatch(password) && 
        RegExp(r'[0-9]').hasMatch(password)) score += 10;
    if ((counts['commonSpecial']! + counts['uncommonSpecial']!) > 1) score += 15;
    
    // 计算最终得分（限制最高分为100）
    double finalScore = score > 100 ? 100 : score;
    
    return PasswordStrength(
      score: finalScore,
      counts: counts,
      suggestions: _generateSuggestions(counts),
    );
  }

  List<String> _generateSuggestions(Map<String, int> counts) {
    List<String> suggestions = [];
    
    if (counts['length']! < 8) {
      suggestions.add('密码长度建议至少8个字符');
    }
    if (counts['uppercase']! == 0) {
      suggestions.add('建议添加大写字母');
    }
    if (counts['lowercase']! == 0) {
      suggestions.add('建议添加小写字母');
    }
    if (counts['numbers']! == 0) {
      suggestions.add('建议添加数字');
    }
    if (counts['commonSpecial']! == 0 && counts['uncommonSpecial']! == 0) {
      suggestions.add('建议添加特殊字符');
    }
    
    return suggestions;
  }

  // 新增：获取特殊字符预览
  String getSpecialCharsPreview({bool includeUncommon = false}) {
    String preview = _commonSpecialChars;
    if (includeUncommon) {
      preview += ' ' + _uncommonSpecialChars;
    }
    return preview;
  }
}

// 新增：密码强度结果类
class PasswordStrength {
  final double score;
  final Map<String, int> counts;
  final List<String> suggestions;

  PasswordStrength({
    required this.score,
    required this.counts,
    required this.suggestions,
  });
} 