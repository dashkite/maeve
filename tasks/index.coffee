import * as genie from "@dashkite/genie"
import presets from "@dashkite/genie-presets"

presets genie

import YAML from "js-yaml"
import * as m from "@dashkite/masonry"

# TODO we need this (node) preset in genie-presets
yaml = ({ input }) ->
  value = YAML.load input
  json = JSON.stringify value
  "module.exports = #{json}"

genie.define "yaml", m.start [
  m.glob "test/**/*.yaml", "."
  m.read
  m.tr yaml
  m.extension ".js"
  m.write "build/node"
]

genie.after "build", "yaml"
