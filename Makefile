CC = clang
TARGET = --target=wasm32-unknown-wasi
SYSROOT = --sysroot /build/wasi-libc/sysroot
LDFLAGS = -Wl,--no-entry -Wl,--export-all
OUTPUT = calculator_world.wasm
SOURCES = calculator_impl.c
GENERATED_HEADERS = calculator_world.h
GENERATED_SOURCES = calculator_world.c
GENERATED_OBJECTS = calculator_world_component_type.o

all: $(OUTPUT)

$(GENERATED_HEADERS) $(GENERATED_SOURCES) $(GENERATED_OBJECTS): calculator_world.wit
	wit-bindgen c $<

$(OUTPUT): $(SOURCES) $(GENERATED_SOURCES) $(GENERATED_OBJECTS)
	$(CC) $(TARGET) $(SYSROOT) $(LDFLAGS) -o $@ $(SOURCES) $(GENERATED_SOURCES) $(GENERATED_OBJECTS)

clean:
	rm -f $(OUTPUT) $(GENERATED_HEADERS) $(GENERATED_SOURCES) $(GENERATED_OBJECTS)

.PHONY: all clean
