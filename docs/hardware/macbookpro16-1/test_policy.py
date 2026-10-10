import unittest

from mbp2019_amdgpu_demand import Policy, SafetyError, Sample


def sample(busy=0, edge=55000, junction=58000):
    return Sample(busy, edge, junction, 4000000)


class PolicyTests(unittest.TestCase):
    def boost(self, policy):
        self.assertEqual(policy.step(0, sample(90))[0], 'low')
        self.assertEqual(policy.step(1, sample(90))[0], 'high')

    def test_idle_stays_low(self):
        p = Policy()
        for now in range(100):
            self.assertEqual(p.step(now, sample())[0], 'low')

    def test_sustained_load_boosts_without_app_names(self):
        self.boost(Policy())

    def test_short_spikes_do_not_boost(self):
        p = Policy()
        for now in range(100):
            self.assertEqual(p.step(now, sample(95 if now % 2 else 0))[0], 'low')

    def test_realistic_low_workload_can_trigger(self):
        p = Policy()
        readings = [77, 56, 87, 63, 84, 61, 74, 73, 74, 78, 68]
        for now, busy in enumerate(readings):
            p.step(now, sample(busy))
        self.assertEqual(p.mode, 'high')

    def test_idle_releases_with_minimum_hold(self):
        p = Policy()
        self.boost(p)
        for now in range(2, 13):
            self.assertEqual(p.step(now, sample())[0], 'high')
        self.assertEqual(p.step(13, sample())[0], 'low')

    def test_reduced_busy_at_higher_clocks_does_not_flap(self):
        p = Policy()
        self.boost(p)
        for now in range(2, 120):
            self.assertEqual(p.step(now, sample(10))[0], 'high')

    def test_new_activity_resets_idle_window(self):
        p = Policy()
        self.boost(p)
        for now in range(2, 100):
            self.assertEqual(p.step(now, sample(30 if now % 6 == 0 else 0))[0], 'high')

    def test_low_mode_cooldown_prevents_immediate_reboost(self):
        p = Policy()
        self.boost(p)
        for now in range(2, 14):
            p.step(now, sample())
        for now in range(14, 22):
            self.assertEqual(p.step(now, sample(100))[0], 'low')
        self.assertEqual(p.step(22, sample(100))[0], 'high')

    def test_edge_thermal_guard_is_immediate(self):
        p = Policy()
        self.boost(p)
        self.assertEqual(p.step(2, sample(100, edge=80000))[0], 'low')
        self.assertTrue(p.hot)

    def test_junction_thermal_guard_is_immediate(self):
        p = Policy()
        self.boost(p)
        self.assertEqual(p.step(2, sample(100, junction=90000))[0], 'low')

    def test_cooldown_requires_thirty_continuous_cool_seconds(self):
        p = Policy()
        self.boost(p)
        p.step(2, sample(100, edge=82000))
        for now in range(3, 20):
            self.assertEqual(p.step(now, sample(100))[0], 'low')
        p.step(20, sample(100, edge=71000))
        for now in range(21, 52):
            self.assertEqual(p.step(now, sample(100))[0], 'low')
        self.assertFalse(p.hot)
        self.assertEqual(p.step(52, sample(100))[0], 'low')
        self.assertEqual(p.step(53, sample(100))[0], 'high')

    def test_invalid_inputs_are_rejected(self):
        for bad in (sample(101), sample(-1), sample(edge=0), sample(junction=150000)):
            with self.assertRaises(SafetyError):
                Policy().step(0, bad)


if __name__ == '__main__':
    unittest.main()
