module ApplicationHelper
  def hbr(str)
    # 改行のみ<br/>に変換してその他は全てエスケープする
    h(str).gsub(/\n/, "<br/>").html_safe
  end

  def link_to_remove_fields(name, f, **html_options)
    # Label management画面でlabelを削除するjavascript発動ボタンを返す
    a = f.hidden_field(:_destroy)
    html_options[:onclick] = ("remove_fields(this)")
    b = link_to name ,'javascript:void()', html_options
    a + b
  end


  def link_to_add_fields_for_label(name, f, association, **html_options)
    # Label management画面でlabelを動的に作成するリンクを返す
    
    # association名の子クラスオブジェクトを生成
    new_object = f.object.class.reflect_on_association(association).klass.new(white_list: "\nOther\nUnknown")

    # child_indexで指定した部分はクリック時にjavascriptで現時刻に
    # 書き換えられユニークな割り当てがされる
    fields = f.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    html_options[:onclick] = ("add_fields(this, \'#{association}\', \'#{escape_javascript(fields)}\')")
    link_to name, 'javascript:void()', html_options


    # RailsCast #197 から参考にしたもの
    # tutorialでは第2引数にエスケープメソッド h が付けられている
    # しかし、rails4ではデフォルトでエスケープされるので、もう一度エスケープすると
    # &などがもう一度エスケープされて上手く動かなくなる
    # 下記の様に第2引数はStringそのままにする必要がある
    # また、rails4からはlink_to_functionが廃止になるらしいので＠サーバーログ
    # 上記のlink_toに、下記サイトを参考に変えることにした。
    # http://modeverv.hateblo.jp/entry/2013/08/31/railscast%23196%2C197_Nested_Model_Formをrails4で動かす
    # link_to_function(name, ("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")") )
  end

  # Label management画面でlabelを動的に作成するリンクを返す(original)
  # def link_to_add_fields(name, f, association, **html_options)
  #   # association名の子クラスオブジェクトを生成
  #   new_object = f.object.class.reflect_on_association(association).klass.new

  #   # child_indexで指定した部分はクリック時にjavascriptで現時刻に
  #   # 書き換えられユニークな割り当てがされる
  #   fields = f.fields_for(association, new_object, child_index: "new_#{association}") do |builder|
  #     render(association.to_s.singularize + "_fields", f: builder)
  #   end
  #   html_options[:onclick] = ("add_fields(this, \'#{association}\', \'#{escape_javascript(fields)}\')")
  #   link_to name, 'javascript:void()', html_options


  #   # RailsCast #197 から参考にしたもの
  #   # tutorialでは第2引数にエスケープメソッド h が付けられている
  #   # しかし、rails4ではデフォルトでエスケープされるので、もう一度エスケープすると
  #   # &などがもう一度エスケープされて上手く動かなくなる
  #   # 下記の様に第2引数はStringそのままにする必要がある
  #   # また、rails4からはlink_to_functionが廃止になるらしいので＠サーバーログ
  #   # 上記のlink_toに、下記サイトを参考に変えることにした。
  #   # http://modeverv.hateblo.jp/entry/2013/08/31/railscast%23196%2C197_Nested_Model_Formをrails4で動かす
  #   # link_to_function(name, ("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")") )
  # end



  def spectrum_for_chart(record)
    ary = record.project.m_z_to_a.zip(record.spectrum).select{|m_z, intensity| m_z && intensity}
    ary.map{|m_z, intensity| "[#{m_z}, #{intensity}]" }.join(",")
  end

  def ticks_for_chart(project)
    quarter = ((project.m_z_end - project.m_z_start) / 4).round(project.m_z_significant_figures_max)
    ticks = [project.m_z_start, quarter, quarter * 2, quarter * 3, project.m_z_end]

    "[" + ticks.join(", ") + "]"
  end

  def m_z_which_have_null(record)
    ary = record.project.m_z_to_a.zip(record.spectrum).select{|m_z, intensity| not intensity }
    ary.map{|m_z, intensity| m_z }.join(", ")
  end
end
