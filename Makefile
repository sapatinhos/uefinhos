smp := 16
mem := 4G
ovmfdir := OVMF
espdir := esp
kernel := $(espdir)/kernel.efi

.PHONY: build clean run

build: $(kernel)

$(kernel):
	mkdir -p $(espdir)
	$(MAKE) -C src
	cp src/kernel.efi $(espdir)/

clean:
	$(MAKE) -C src clean
	rm -rf $(espdir)

run: $(kernel)
	qemu-system-x86_64 \
		-enable-kvm \
		-m $(mem) \
		-smp $(smp) \
		-cpu host \
		-drive if=pflash,format=raw,readonly=on,file="$(ovmfdir)/OVMF_CODE.fd" \
		-drive if=pflash,format=raw,file="$(ovmfdir)/OVMF_VARS.fd" \
		-drive format=raw,file=fat:rw:$(espdir) \
		-net none \
		-nographic
