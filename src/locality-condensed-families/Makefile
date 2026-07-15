GHC := ghc
GHCFLAGS := -Wall -Wextra -Werror -O2
TARGET := locality-demo

.PHONY: all run clean

all: $(TARGET)

$(TARGET): Main.hs Locality.hs
	$(GHC) $(GHCFLAGS) Main.hs Locality.hs -o $(TARGET)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) *.hi *.o
