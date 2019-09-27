defmodule Mix.Thesis.Utils do
  @moduledoc false

  @doc false
  def get_module do
    Mix.Project.get
    |> Module.split
    |> Enum.reverse
    |> Enum.at(1)
  end

  @doc false
  def status_msg(status, message),
    do: IO.puts "#{IO.ANSI.green}* #{String.pad_leading(status, 10)}#{IO.ANSI.reset} #{message}"

  @doc false
  def debug(message), do: IO.puts "==> #{message}"
  @doc false
  def info(message),  do: IO.puts "==> #{IO.ANSI.green}#{message}#{IO.ANSI.reset}"
  @doc false
  def warn(message),  do: IO.puts "==> #{IO.ANSI.yellow}#{message}#{IO.ANSI.reset}"
  @doc false
  def notice(message), do: IO.puts "#{IO.ANSI.yellow}#{message}#{IO.ANSI.reset}"
  @doc false
  def error(message), do: IO.puts "==> #{IO.ANSI.red}#{message}#{IO.ANSI.reset}"

  @doc false
  def overwrite_file(:skip, _dest_file_path), do: :ok
  @doc false
  def overwrite_file(contents, dest_file_path) do
    File.write! dest_file_path, contents
  end

  @doc false
  def render_eex({source, target}) do
    source = Path.join(Application.app_dir(:thesis), source)
    rendered = EEx.eval_file(source, [base: Mix.Phoenix.base])
    {rendered, target}
  end

  @doc false
  def replace_yourapp({contents, target}, base) do
    {
      String.replace(contents, "YOURAPP", base),
      String.replace(target, "YOURAPP", base)
    }
  end

  @doc false
  def copy_to_target({contents, target}) do
    if File.exists?(target) do
      status_msg("exists", target)
    else
      File.write!(target, contents)
      status_msg("creating", target)
    end
  end

  # Taken from mix phoenix.gen.model
  # https://github.com/phoenixframework/phoenix/blob/d3af3397c1f47381dd7ea69869772174a0c1811b/lib/mix/tasks/phoenix.gen.model.ex#L198
  @doc false
  def timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end
