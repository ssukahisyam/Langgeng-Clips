enum PremiumFeature {
  unlimitedExports,
  removeWatermark,
  premiumTemplates,
  priorityRendering,
}

class PremiumTemplateLock {
  const PremiumTemplateLock({
    this.premiumTemplateIds = const {'gaming', 'talking_head'},
  });

  final Set<String> premiumTemplateIds;

  bool isLocked(String templateId, {required bool isPremium}) {
    return !isPremium && premiumTemplateIds.contains(templateId);
  }
}
