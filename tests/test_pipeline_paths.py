import unittest
import os
import ast

class TestPipelinePathStability(unittest.TestCase):
    """
    Tests to ensure that our main pipeline scripts maintain cross-platform path stability.
    They should avoid hardcoded strings with slashes for paths where os.path.join should be used.
    """
    def setUp(self):
        self.root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.orchestrator = os.path.join(self.root_dir, 'user', 'assets', 'orchestrator.py')
        self.renderer = os.path.join(self.root_dir, 'user', 'assets', 'render_html_from_layout.py')

    def test_scripts_exist(self):
        self.assertTrue(os.path.exists(self.orchestrator), "orchestrator.py must exist")
        self.assertTrue(os.path.exists(self.renderer), "render_html_from_layout.py must exist")

    def test_no_hardcoded_absolute_slashes_in_renderer(self):
        with open(self.renderer, 'r') as f:
            code = f.read()
        
        # We ensure they don't hardcode absolute posix paths like "/Users/" or "/home/"
        # since we want workspace-relative cross-platform paths.
        self.assertNotIn('"/Users/', code)
        self.assertNotIn("'/Users/", code)
        self.assertNotIn('"/home/', code)
        self.assertNotIn("'/home/", code)

if __name__ == '__main__':
    unittest.main()
