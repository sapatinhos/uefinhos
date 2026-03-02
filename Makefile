# ---------------------------------------------------------------------------- #

ovmf ?= OVMF
esp  ?= ESP
smp  ?= 2
mem  ?= 1G
cpu  ?= host

# ---------------------------------------------------------------------------- #

efibin := src/kernel.efi
bootx64 := $(esp)/EFI/BOOT/BOOTX64.EFI
posix-uefi := posix-uefi/uefi/Makefile

# ---------------------------------------------------------------------------- #

.PHONY: build clean run

# ---------------------------------------------------------------------------- #

build: $(bootx64)

$(posix-uefi):
	git submodule update --init --recursive posix-uefi

$(efibin): $(posix-uefi)
	$(MAKE) -C $(@D)

$(bootx64): $(efibin)
	mkdir -p $(@D)
	cp $< $@

clean:
	$(MAKE) -C $(dir $(efibin)) clean
	rm -rf $(esp)

# ---------------------------------------------------------------------------- #

run: build
	qemu-system-x86_64 \
		-enable-kvm \
		-m $(mem) \
		-smp $(smp) \
		-cpu $(cpu) \
		-drive if=pflash,format=raw,readonly=on,file="$(ovmf)/OVMF_CODE.fd" \
		-drive if=pflash,format=raw,file="$(ovmf)/OVMF_VARS.fd" \
		-drive format=raw,file=fat:rw:$(esp) \
		-net none

# ---------------------------------------------------------------------------- #
