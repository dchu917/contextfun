"""Regression tests for _neutralize_pack_sentinels (contextfun/cli.py).

Entry content that contains a literal </ctx-pack> would prematurely close the
<ctx-pack>…</ctx-pack> wrapper emitted by the resume skill, so a consumer that
splits on the literal tag mis-parses the pack. The guard inserts a zero-width
space inside any such tag: the literal match breaks while the text stays
visually identical.
"""

import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CLI_PY = ROOT / "contextfun" / "cli.py"

ZWSP = "​"


def _load_cli_module():
    spec = importlib.util.spec_from_file_location("ctx_cli_module", CLI_PY)
    module = importlib.util.module_from_spec(spec)
    assert spec is not None and spec.loader is not None
    spec.loader.exec_module(module)
    return module


class PackSentinelGuardTests(unittest.TestCase):
    def setUp(self):
        self.cli = _load_cli_module()
        self.guard = self.cli._neutralize_pack_sentinels

    def test_closing_tag_no_longer_matches_literal(self):
        out = self.guard("notes </ctx-pack> more")
        self.assertNotIn("</ctx-pack>", out)
        self.assertIn("</ctx-pack" + ZWSP + ">", out)

    def test_opening_tag_no_longer_matches_literal(self):
        out = self.guard("<ctx-pack> injected")
        self.assertNotIn("<ctx-pack>", out)
        self.assertIn("<ctx-pack" + ZWSP + ">", out)

    def test_guarded_text_is_visually_identical_when_zwsp_stripped(self):
        evil = "a </ctx-pack> b <ctx-pack> c"
        self.assertEqual(self.guard(evil).replace(ZWSP, ""), evil)

    def test_benign_text_is_unchanged(self):
        benign = "ordinary entry with <other> tags & </closing> bits"
        self.assertEqual(self.guard(benign), benign)

    def test_multiple_occurrences_all_guarded(self):
        out = self.guard("</ctx-pack> x </ctx-pack>")
        self.assertNotIn("</ctx-pack>", out)
        self.assertEqual(out.count("</ctx-pack" + ZWSP + ">"), 2)


if __name__ == "__main__":
    unittest.main()
