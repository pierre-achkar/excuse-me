enum AnalyticsEvent {
  appOpen,
  generationCompleted,
  regenerate,
  copy,
  share,
  returnUse,
}

abstract class AnalyticsClient {
  Future<void> record(AnalyticsEvent event);
}

class NoOpAnalyticsClient implements AnalyticsClient {
  const NoOpAnalyticsClient();

  @override
  Future<void> record(AnalyticsEvent event) async {}
}
