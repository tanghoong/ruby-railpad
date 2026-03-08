require "open3"
require "timeout"

class GistExecutionService
  # Keywords that could allow filesystem access, shell commands, or escape the process.
  # Checked as whole words — e.g. "send" matches but "message" does not.
  BLOCKLIST = %w[
    system exec spawn fork backtick eval binding
    require load open File Dir IO ENV Process
    ObjectSpace Kernel at_exit trap
  ].freeze

  TIMEOUT_SECONDS = 5
  MAX_OUTPUT_BYTES = 10_000

  def initialize(gist)
    @gist = gist
  end

  def call
    violation = BLOCKLIST.find { |term| @gist.code.match?(/\b#{Regexp.escape(term)}\b/) }
    return blocked_result(violation) if violation

    run_subprocess
  end

  private

  def run_subprocess
    output = nil
    Timeout.timeout(TIMEOUT_SECONDS) do
      # Array-form avoids shell interpolation — safe on Windows and Unix
      output, = Open3.capture2e("ruby", "-e", @gist.code)
    end
    { output: output.to_s.slice(0, MAX_OUTPUT_BYTES), error: false }
  rescue Timeout::Error
    { output: "Timed out after #{TIMEOUT_SECONDS} seconds.", error: true }
  rescue => e
    { output: "Execution error: #{e.message}", error: true }
  end

  def blocked_result(term)
    { output: "Blocked: '#{term}' is not permitted in this sandbox.", error: true }
  end
end
