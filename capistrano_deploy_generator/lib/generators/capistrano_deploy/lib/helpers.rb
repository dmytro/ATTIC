require 'highline/import'

class CapistranoDeployGenerator < Rails::Generators::NamedBase  
  private

  # See http://stackoverflow.com/questions/2903200/watir-changes-highlines-ask-method
  def ask(*p, &b)
    HighLine.new.ask(*p, &b)
  end

  def ask_default propmt, default, &b
    ask(propmt) { |q| q.default = default; q.readline = true }
  end

  def agree_default quest, default=nil
    agree(quest) {  |q| q.default = default }
  end

  ##
  # Menu with default element and add own item.
  def menu_with_default header, items, default

    idx = items.index default
    items[idx] = "=> [ #{default} ]" if idx

    choose do |menu|
      menu.header = header
      menu.prompt =%Q{
> Type 1 to add, number or name or Enter to accept default. 
> Default is specified by '=>' mark.
: }

      menu.choice  ('*** Other ***') { return ask "Enter new item: " }
      menu.choices *(items)
      menu.readline = true
      menu.hidden("") { puts default; return default }  if default
    end
  end

  def recipe file
    "load File.expand_path(\"config/deploy/recipes/#{file}.rb\")"
  end
end
