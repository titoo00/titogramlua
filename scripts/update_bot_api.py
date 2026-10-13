#!/usr/bin/env python3
"""Generate wrappers for Bot API methods absent from the hand-written Lua modules."""

from __future__ import annotations

import html.parser
import pathlib
import re
import urllib.request

API_URL = "https://core.telegram.org/bots/api"
OUTPUT = pathlib.Path("src/methods/updates.lua")
BEGIN = "    -- BEGIN GENERATED BOT API METHODS"
END = "    -- END GENERATED BOT API METHODS"


class MethodsParser(html.parser.HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.heading = ""
        self.heading_text: list[str] = []
        self.in_methods = False
        self.in_h4 = False
        self.method_text: list[str] = []
        self.methods: set[str] = set()

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag in ("h2", "h3"):
            self.heading = tag
            self.heading_text = []
        elif tag == "h4" and self.in_methods:
            self.in_h4 = True
            self.method_text = []

    def handle_endtag(self, tag: str) -> None:
        if tag == "h4" and self.in_h4:
            name = "".join(self.method_text).strip()
            if re.fullmatch(r"[A-Za-z][A-Za-z0-9]*", name):
                self.methods.add(name)
            self.in_h4 = False
        if tag == self.heading and self.heading:
            title = " ".join("".join(self.heading_text).lower().split())
            if "available methods" in title:
                self.in_methods = True
            elif "available types" in title:
                self.in_methods = False
            self.heading = ""

    def handle_data(self, data: str) -> None:
        if self.heading:
            self.heading_text.append(data)
        if self.in_h4:
            self.method_text.append(data)


def snake_case(name: str) -> str:
    return re.sub(r"(?<!^)(?=[A-Z])", "_", name).lower()


def main() -> None:
    request = urllib.request.Request(API_URL, headers={"User-Agent": "titogramlua-bot-api-updater"})
    with urllib.request.urlopen(request, timeout=30) as response:
        document = response.read().decode("utf-8")

    parser = MethodsParser()
    parser.feed(document)
    if not parser.methods:
        raise RuntimeError("No Bot API methods found; refusing to replace generated wrappers.")

    source = OUTPUT.read_text(encoding="utf-8")
    generated_pattern = re.compile(
        rf"\n{re.escape(BEGIN)}\n.*?\n{re.escape(END)}(?=\n)", re.DOTALL
    )
    clean_output, marker_count = generated_pattern.subn("", source)
    if marker_count != 1:
        raise RuntimeError("Expected exactly one generated-wrapper marker block.")

    implemented: set[str] = set()
    for path in pathlib.Path("src/methods").glob("*.lua"):
        module = clean_output if path == OUTPUT else path.read_text(encoding="utf-8")
        implemented.update(re.findall(r"function\s+api\.([a-z][a-z0-9_]*)\s*\(", module))
        implemented.update(re.findall(r"api\.([a-z][a-z0-9_]*)\s*=", module))

    wrappers: list[str] = []
    count = 0
    for method in sorted(parser.methods, key=str.casefold):
        lua_name = snake_case(method)
        if lua_name in implemented:
            continue
        wrappers.extend([
            f"    -- Generated wrapper for official Bot API method {method}.",
            f"    -- Pass parameters in an options table; files may be passed as a second table.",
            f"    function api.{lua_name}(opts, files)",
            f"        return api.call_method('{method}', opts, files)",
            "    end",
            "",
        ])
        count += 1

    block = "\n".join([BEGIN, *wrappers, END])
    updated = generated_pattern.sub("\n" + block, source)
    OUTPUT.write_text(updated, encoding="utf-8")
    print(f"Found {len(parser.methods)} official methods; generated {count} wrappers.")


if __name__ == "__main__":
    main()
