load("assert.star", "assert")

assert.eq(type(tf), "Terraform")
assert.ne(tf.version, "")
assert.eq("aws" in tf.provider, False)

# attr names
assert.eq("version" in dir(tf), True)
assert.eq("backend" in dir(tf), True)
assert.eq("provider" in dir(tf), True)

# provider
qux = tf.provider("aws", "2.13.0", "qux", region="qux")
bar = tf.provider("aws", "2.13.0", "bar", region="bar")
assert.eq(bar.region, "bar")

assert.eq(len(tf.provider["aws"]), 2)
assert.eq("foo" in tf.provider["aws"], False)
assert.eq(tf.provider["aws"]["bar"] == None, False)
assert.eq(tf.provider["aws"]["bar"], bar)
assert.eq(tf.provider["aws"]["bar"].region, "bar")

# type
assert.eq(type(tf.provider), "ProviderCollection")

# backend
assert.eq(tf.backend, None)

tf.backend = backend("local")
tf.backend.path = "foo"
assert.eq(str(tf.backend), "Backend<local>")

def backendWrongType(): tf.backend = "foo"
assert.fails(backendWrongType, "unexpected value string at backend")
assert.eq(str(tf.backend), "Backend<local>")

# pop provider
baz = tf.provider("aws", "2.13.0", "baz", region="baz")
pop = tf.provider["aws"].pop("baz")

# hcl
assert.eq(hcl(tf), "" +
'terraform {\n' + \
'  backend "local" {\n' + \
'    path = "foo"\n' + \
'  }\n' + \
'}\n' + \
'\n' + \
'provider "aws" {\n' + \
'  alias   = "qux"\n' + \
'  version = "2.13.0"\n' + \
'  region  = "qux"\n' + \
'}\n' + \
'\n' + \
'provider "aws" {\n' + \
'  alias   = "bar"\n' + \
'  version = "2.13.0"\n' + \
'  region  = "bar"\n' + \
'}\n\n')