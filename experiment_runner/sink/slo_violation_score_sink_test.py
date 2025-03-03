from experiment_runner.scenario import SLO
from experiment_runner.sink.slo_violation_score_sink import SloViolationScoreSink

class MockSlo(SLO):
    def __init__(self, query, threshold, is_bigger_better):
        super().__init__(query, threshold, is_bigger_better)

    def get_value(self) -> float:
        return 0

class SloViolationScoreSinkTest:
    def __init__(self):
        super().__init__()
        self.testee = SloViolationScoreSink()

    def test(self):
        self.testee.evaluate_slo(MockSlo(None, 3, False))
        print(self.testee.get_score())

if __name__ == '__main__':
    SloViolationScoreSinkTest().test()
