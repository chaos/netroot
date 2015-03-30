sbin_SCRIPTS = \
	configpxe netroot-rebuild netroot-setdefault \
	netroot-kdumplinks netroot-memtestlink

man8_MANS = configpxe.8

postinstdir = /etc/kernel/postinst.d
postinst_SCRIPTS = netroot-postinst

prermdir = /etc/kernel/prerm.d
prerm_SCRIPTS = netroot-prerm

EXTRA_DIST = \
	configpxe \
	configpxe.8 \
	netroot-rebuild \
	netroot-setdefault \
	netroot-postinst \
	netroot-prerm \
	netroot-kdumplinks \
	netroot-memtestlink
