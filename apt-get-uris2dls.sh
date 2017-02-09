#! /bin/sh
set -e
trap 'test $? = 0 || echo "$0 failed!" >& 2' 0
{
	cat << 'EOF'
#! /bin/sh
set -e

dl() {
	wget -c -q -O "$f" "$1${2+"$f"}"
}

compare_cs() {
	local s
	s=`$1 -b -- "$f" | cut -c -$2`
	if test x"$s" != x"$3"
	then
		echo "File '$f' has bad checksum!" >& 2
		false || exit
	fi
}

md5() {
	compare_cs md5sum 32 "$1"
}

sha256() {
	compare_cs sha256sum 64 "$1"
}

EOF
	while IFS= read -r u
	do
		r=${u##*"'"}; u=${u%"'$r"}; u=${u#"'"}; r=${r#" "}
		eval "set -- $r"
		f=$1; s=$2; m=$3
		echo "f='$f'"
		if test x"${u%"$f"}" != x"$u"
		then
			echo "dl '${u%"$f"}' +"
		else
			echo "dl '$u'"
		fi
		if s=${m#MD5Sum:} && test x"$s" != x"$m"
		then
			echo "md5 $s"
		elif s=${m#SHA256:} && test x"$s" != x"$m"
		then
			echo "sha256 $s"
		else
			echo "Unsupported checksum type: $m" >& 2
			false || exit
		fi
	done
} | tee dls.sh
