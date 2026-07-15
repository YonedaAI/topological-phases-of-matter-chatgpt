GHC ?= ghc
GHCFLAGS := -Wall -Wextra -Werror -O0
TARGET := synthesis-validator
SOURCES := Main.hs Core.hs Properties.hs ContractChecks.hs

.PHONY: all test clean

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(GHC) $(GHCFLAGS) -i. -o $(TARGET) Main.hs

test: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) *.hi *.o
