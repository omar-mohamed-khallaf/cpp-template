#include <boost/json.hpp>
#include <boost/json/serialize.hpp>
#include <iostream>
#include <sqlite3.h>

auto main() -> int {
    std::cout << "SQLite Version: " << sqlite3_libversion() << '\n';
    boost::json::object obj;
    obj["project"] = "Boost.JSON Test";
    obj["version"] = 1.0;
    obj["features"] = {"parsing", "serialization", "speed"};
    obj["active"] = true;

    // 2. Serialization: Convert object to a string
    std::string str = boost::json::serialize(obj);
    std::cout << "Serialized JSON:\n" << str << "\n\n";

    // 3. Parsing: Convert a string back into a JSON value
    std::string raw_input = R"({"user": "user1", "id": 42, "tags": ["AI", "C++"]})";

    // We use error_code to avoid exceptions for simple checks
    boost::system::error_code error;
    boost::json::value json = boost::json::parse(raw_input, error);

    if (error) {
        std::cerr << "Parsing failed: " << error.message() << '\n';
        return 1;
    }

    // 4. Accessing data
    // Note: Use .as_object(), .as_string(), etc., to access specific types
    std::string user = json.as_object()["user"].as_string().c_str();
    int64_t id = json.as_object()["id"].as_int64();

    std::cout << "Parsed Data:\n";
    std::cout << "User: " << user << "\n";
    std::cout << "ID: " << id << "\n";
    return 0;
}
