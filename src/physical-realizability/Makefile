GHC ?= ghc
GHCFLAGS := -Wall -Wextra -Werror -O2
TARGET := physical-realizability-demo

.PHONY: all run clean

all: $(TARGET)

$(TARGET): Main.hs Realizability.hs
	$(GHC) $(GHCFLAGS) Main.hs Realizability.hs -o $(TARGET)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) *.hi *.o
