package types

import (
	"fmt"
	"io/ioutil"
	"log"
	"testing"

	"github.com/mcuadros/ascode/starlark/module/os"
	"github.com/mcuadros/ascode/starlark/test"
	"github.com/mcuadros/ascode/terraform"
	"go.starlark.net/resolve"
	"go.starlark.net/starlark"
)

var id int

func init() {
	NameGenerator = func() string {
		id++
		return fmt.Sprintf("id_%d", id)
	}

	resolve.AllowLambda = true
	resolve.AllowNestedDef = true
	resolve.AllowFloat = true
	resolve.AllowSet = true
	resolve.AllowGlobalReassign = true
}

func TestProvider(t *testing.T) {
	doTest(t, "testdata/provider.star")
}

func TestProvisioner(t *testing.T) {
	doTest(t, "testdata/provisioner.star")
}

func TestNestedBlock(t *testing.T) {
	doTest(t, "testdata/nested.star")
}

func TestResource(t *testing.T) {
	doTest(t, "testdata/resource.star")
}

func TestHCL(t *testing.T) {
	doTest(t, "testdata/hcl.star")
}

func TestHCLIntegration(t *testing.T) {
	doTest(t, "testdata/hcl_integration.star")
}

func doTest(t *testing.T, filename string) {
	doTestPrint(t, filename, nil)
}

func doTestPrint(t *testing.T, filename string, print func(*starlark.Thread, string)) {
	id = 0

	pm := &terraform.PluginManager{".providers"}

	log.SetOutput(ioutil.Discard)
	thread := &starlark.Thread{Load: load, Print: print}
	thread.SetLocal("base_path", "testdata")
	thread.SetLocal(PluginManagerLocal, pm)

	test.SetReporter(thread, t)

	predeclared := starlark.StringDict{
		"provisioner": BuiltinProvisioner(),
		"backend":     BuiltinBackend(),
		"hcl":         BuiltinHCL(),
		"fn":          BuiltinFunctionComputed(),
		"evaluate":    BuiltinEvaluate(),
		"tf":          NewTerraform(pm),
	}

	_, err := starlark.ExecFile(thread, filename, nil, predeclared)
	if err != nil {
		if err, ok := err.(*starlark.EvalError); ok {
			t.Fatal(err.Backtrace())
		}
		t.Fatal(err)
	}
}

// load implements the 'load' operation as used in the evaluator tests.
func load(thread *starlark.Thread, module string) (starlark.StringDict, error) {
	if module == "assert.star" {
		return test.LoadAssertModule()
	}

	if module == os.ModuleName {
		return os.LoadModule()
	}

	return nil, fmt.Errorf("load not implemented")
}
