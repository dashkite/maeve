url = ({ scheme, domain, port, target }) ->
  new URL "#{scheme}://#{domain}:#{port}#{target}"

export { url  }