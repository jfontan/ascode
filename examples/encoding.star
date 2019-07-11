load("encoding/json", "json")
load("encoding/base64", "base64")
load("os", "os")
load("path/filepath", "filepath")

ignition = provider("ignition", "1.1.0")

user = ignition.data.user()
user.name = "foo"
user.uid = 42
user.groups = ["foo", "bar"]
user.system = True

print(json.dumps(user.__dict__))
print(base64.encode("foo"))

print(filepath.base(os.getwd()))