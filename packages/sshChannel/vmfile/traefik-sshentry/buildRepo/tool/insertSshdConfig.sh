# /bin/sh
sed -ex

insertSshdConfig() {
  local key="$1"
  local value="$2"

  local lineNum lineTxt
  local sshdConfigPath="/etc/ssh/sshd_config"
  local insertTxt="$key $value"

  if fnGetLineNum "$insertTxt" "$sshdConfigPath" ; then
    return
  fi

  if fnGetLineNum "$key" "$sshdConfigPath" ; then
    lineNum=$rtnGetLineNum_lineNum
    lineTxt=$rtnGetLineNum_lineTxt
    sed -i "${lineNum}c #$lineTxt" "$sshdConfigPath"
    sed -i "${lineNum}a $insertTxt" "$sshdConfigPath"
    return
  fi

  if fnGetLineNum "#$key" "$sshdConfigPath" ; then
    lineNum=$rtnGetLineNum_lineNum
    sed -i "${lineNum}a $insertTxt" "$sshdConfigPath"
    return
  fi

  echo "$insertTxt" >> "$sshdConfigPath"
}

rtnGetLineNum_lineNum=''
rtnGetLineNum_lineTxt=''
fnGetLineNum() {
  local key="$1"
  local filePath="$2"

  local lineInfoTxt=`grep -nm 1 "^$key" "$filePath"`
  rtnGetLineNum_lineNum=`
    echo "$lineInfoTxt" |
      sed "s/^ *\([0-9]\+\):\(.*\)$/\1/"
  `
  rtnGetLineNum_lineTxt=`
    echo "$lineInfoTxt" |
      sed "s/^ *\([0-9]\+\):\(.*\)$/\2/"
  `
  [ -n "$rtnGetLineNum_lineNum" ] && return 0 || return 1
}

insertSshdConfig "$@"

