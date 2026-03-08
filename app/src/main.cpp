#include <iostream>
#include <json/json.h>
#include <sqlite3.h>

auto main() -> int {
    Json::Value root;
    root["app"] = "Superbuild Test";
    std::cout << root.toStyledString() << '\n';

    std::cout << "SQLite Version: " << sqlite3_libversion() << '\n';
    return 0;
}
