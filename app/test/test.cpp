#include <gtest/gtest.h>

namespace {
constexpr auto factorial(int num) -> int64_t {
    if (num < 2) {
        return 1;
    }
    return num * factorial(num - 1);
}
} // namespace

TEST(FactorialTest, HandlesZeroInput) { EXPECT_EQ(factorial(0), 1); }

// Tests factorial of positive numbers.
TEST(factorialTest, HandlesPositiveInput) {
    EXPECT_EQ(factorial(1), 1);
    EXPECT_EQ(factorial(2), 2);
    EXPECT_EQ(factorial(3), 6);
    EXPECT_EQ(factorial(8), 40320);
}

auto main(int argc, char **argv) -> int {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
