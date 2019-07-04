load("assert.star", "assert")

aws = provider("aws", "2.13.0")

ami = aws.data.ami()
assert.eq(type(ami.architecture), "computed")
assert.eq(str(ami.architecture), '"${data.aws_ami.8731.architecture}"')

web = aws.resource.instance()
web.ami = ami.id
assert.eq(type(web.ami), "computed")
assert.eq(str(web.ami), '"${data.aws_ami.8731.id}"')