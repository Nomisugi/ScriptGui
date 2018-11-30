def line_edit line
  line.chop!
  array = line.split /\s/
  array.delete("")
  array.compact!

  if array.size > 1
    str = array[0].to_s + " " + array[1..array.size].to_s
  elsif
    str = array[0].to_s
  end
  return str
end

#編集されたスクリプトを評価してGUIのセーブファイル形式で保存
def script_export script_file, ps_file
#   if File::exist?(ps_file)
#     file = File::unlink(ps_file)
#   end
  ps = PStore.new(ps_file)
  str = Phi::StringList.new
  func_name = ""
  func_flag = false
  temp_text = ""
  i = 0

  initial_load
  
  ps.transaction{|ps|

    port = Phi::StringList.new
    cycle = Phi::StringList.new
    alarm = Phi::StringList.new
    func = Phi::StringList.new
    
    #関数の洗い出し
    file = File.open script_file, "r"
    file.each do |line|
      if line =~ /^\s*\[port_in\d+\]/
        port.add line.chop
      elsif line =~ /^\s*\[cycle\d+\]/
        cycle.add line.chop
      elsif line =~ /^\s*\[alarm\d+\]/
        alarm.add line.chop
      elsif line =~ /^\s*\[func_.*\]/
        func.add line.chop
      end
    end
    ps["[initialize]"] = "[initialize]"
    ps["[port_in]"] = port.text
    ps["[cycle]"] = cycle.text
    ps["[alarm]"] = alarm.text
    ps["[func_user]"] = func.text
    file.close
    
    count = 0
    #関数毎の設定を取得(initialzie)
    file = File.open script_file, "r"
    file.each do |line|
      if func_flag && line =~ /^\s*end/
        func_flag = false
        name = "[initialize]0"
        ps[name] = str.text 
        str.clear
      end

      if func_flag
        if !(line =~ /^\s*#/ ) && (line.size > 3)
          str.add line_edit(line)
        end
      end

      if line =~ /^\s*\[initialize\]/
        func_flag = true
        func_name = line_edit(line)
      end
    end
    
    #関数毎の設定を取得(port_in)
    file = File.open script_file, "r"
    file.each do |line|
      if func_flag && line =~ /^\s*end/
        name = "[port_in]" + count.to_s
        ps[name] = str.text
        str.clear
        func_flag = false
      end

      if func_flag
        if !(line =~ /^\s*#/)
          str.add line_edit(line)
        end
      end

      if line =~ /^\s*\[port_in\d+\]/
        count = port.index_of line.chop
        func_flag = true
      end
    end

    #関数毎の設定を取得(alarm)
    file = File.open script_file, "r"
    file.each do |line|
      if func_flag && line =~ /^\s*end/
        name = "[alarm]" + count.to_s
        ps[name] = str.text
        str.clear
        func_flag = false
      end

      if func_flag
        if !(line =~ /^\s*#/)
          str.add line_edit(line)
        end
      end

      if line =~ /^\s*\[alarm\d+\]/
        count = alarm.index_of line.chop
        func_flag = true
      end
    end

    #関数毎の設定を取得(cycle)
    file = File.open script_file, "r"
    file.each do |line|
      if func_flag && line =~ /^\s*end/
        name = "[cycle]" + count.to_s
        ps[name] = str.text
        str.clear
        func_flag = false
      end

      if func_flag
        if !(line =~ /^\s*#/)
          str.add line_edit(line)
        end
      end

      if line =~ /^\s*\[cycle\d+\]/
        count = cycle.index_of line.chop
        func_flag = true
      end
    end

    #関数毎の設定を取得(func_user)
    file = File.open script_file, "r"
    file.each do |line|
      if func_flag && line =~ /^\s*end/
        name = "[func_user]" + count.to_s
        ps[name] = str.text
        str.clear
        func_flag = false
      end

      if func_flag
        if !(line =~ /^\s*#/)
          str.add line_edit(line)
        end
      end

      if line =~ /^\s*\[func_.*\]/
        count = func.index_of line.chop
        func_flag = true
      end
    end

    file = File.open script_file, "r"
    #認識関数の取り出し
    recog_flag = false
    file.each do |line|
      #関数の取り出し
      if recog_flag && line =~ /^\s*end/
        recog_flag = false
        if func_name =~ /\s*\[recog\d_/
          name = func_name.gsub("_func", "]").chop
          ps[name] = str.text
        else
          ps[func_name] = str.text
        end
        str.clear
      end

      if recog_flag
        if !(line =~ /^\s*#/)
          text = line.chop
          #認識単語「|」の場合
          if text =~ /^\s*\|/
            num = str.count-1
            str[num] = str[num] + text
          elsif
            str.add text.to_s
          end
        end
      end

      if func_flag
        if !(line =~ /^\s*#/)
          str.add line_edit(line)
        end
      end
      
      if line =~ /^\s*\[recog\d*.*\]/
        recog_flag = true
        func_name = line_edit(line)
        next
      end
    end
    
    file.close
  }
end
