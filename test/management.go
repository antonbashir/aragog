package main

import (
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"github.com/tarantool/go-tarantool/v2"
)

func ReloadStorage(connection *tarantool.Connection) error {
	files := map[string]string{}
	err := filepath.WalkDir("storage", func(path string, d fs.DirEntry, err error) error {
		if !d.IsDir() {
			content, err := os.ReadFile(path)
			if err != nil {
				return nil
			}
			path = filepath.ToSlash(path)
			files[strings.ReplaceAll(path, "storage/", "test/")] = string(content)
		}
		return nil
	})
	if err != nil {
		return err
	}
	_, err = connection.Do(tarantool.NewCallRequest("reload").Args([]interface{}{map[string]interface{}{"module": "test", "files": files}})).Get()
	return err
}
