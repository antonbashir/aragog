package main

import (
	"context"
	"fmt"
	"io/fs"
	"os"
	"time"

	"github.com/tarantool/go-tarantool/v2"
)

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	opts := tarantool.Opts{
		Timeout: time.Second,
	}
	reloaderConnection, err := tarantool.Connect(ctx, tarantool.NetDialer{
		Address:  "127.0.0.1:3301",
		User:     "reloader",
		Password: "test",
	}, opts)
	if err != nil {
		fmt.Println("Connection refused:", err)
		return
	}

	moduleConnection, err := tarantool.Connect(ctx, tarantool.NetDialer{
		Address:  "127.0.0.1:3301",
		User:     "test",
		Password: "test",
	}, opts)
	if err != nil {
		fmt.Println("Connection refused:", err)
		return
	}

	os.WriteFile("storage/constants/init.lua", []byte("return { value = 42 }"), fs.FileMode(os.O_TRUNC))
	err = ReloadStorage(reloaderConnection)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	data, err := moduleConnection.Do(tarantool.NewCallRequest("services.test.test")).Get()
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Println("Data:", data)
	}

	os.WriteFile("storage/constants/init.lua", []byte("return { value = 43 }"), fs.FileMode(os.O_TRUNC))
	err = ReloadStorage(reloaderConnection)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	data, err = moduleConnection.Do(tarantool.NewCallRequest("services.test.test")).Get()
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Println("Data:", data)
	}
}
