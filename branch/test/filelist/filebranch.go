/********************************************************
 * 比对文件目录 版本
 * Author: 闲人一小枚
 * Date: 2018-04-10
 *******************************************************/

package main

import (
	// "mahonia"
	// "compress/gzip"
	// "archive/tar"
	"io"
	"os"

	// "log"
	"archive/zip"
	"bytes"
	"compress/zlib"
	"crypto/md5"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os/exec"
	"path"
	"path/filepath"
	"regexp"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/axgle/mahonia"
)

type Config struct {
	OnDataDir              string // 目录
	OnDataPath             string // 源目录
	GoDataPath             string // 目标目录
	GoServerVersionPath    string // 版本文件放到服务端目录
	ClientInitialCsvPath   string // 客户预加载文件传位置
	ClientInitialJsonFile  string // 客户预加载Json 文件
	CsvFilesPath           string // 版本csv文件位置
	ClientSwfPath          string // 运行swf文件目录
	ManifestPath           string // js 版本控制文件
	SettingPath            string // 客户端setting文件修改
	PlatformConfigJsonPath string // 平台配置文件目录
	IsZip                  bool   // 是否压缩
	JsZip                  bool   // 是否压缩
	CompressorType         string // 压缩方式
	ClinetOutFileType      string // 客户端导出文件类型
	IsAll                  bool   // 是否全版打
	CpuDouble              int    // cpu倍数
}

type Item struct {
	MD5     string
	Version string
	Path    string
}

type Groups1 struct {
	Keys string
	Name string
}
type ClientJson struct {
	Groups []Groups1
	// Resources    [] Resources1
}

// 平台文件配置
type PlatformConfig struct {
	IsPack                 bool   // 是否打包
	Platform_id            string // 平台名
	Cdn                    string // cnd地址
	Channel                string // 渠道标识
	Server_list_url_recent string // 向请求服务请求列表
	Server_list_url_all    string // 请求最近登录列表
	Is_product             string //
	Index_html             string // index.html平台的名字
	Index_remove_version   bool   // 是否移除index.html文件的版本文件
}

var flaConfigPath = "config.json"    // 配置读取文件
var zibSuffix = ".bin"               // 压缩后缀
var version_name = "version.txt"     // 版本文件名字
var versionPath = ""                 // 版本路径
var initial_name = "initial_csv.csv" // 客户预加载文件名字
var initialPath = ""                 // 客户预加载文件传位置
var goCsvFilesPath = "filelist/"     // 版本csv文件位置
var goDataPath = ""                  // 源目录
var goClinetDir = ""                 // 资源上一级目录

var goVersionPath = ""   // 存入的版本文件目录
var jsClientZipName = "" // 客户js集合zip文件名字

var clienJson ClientJson
var platformConfig PlatformConfig
var config Config
var items map[string]*Item
var currDateVersion string    // 当前日期版本
var currDateTime string       // 当前日期
var minCurrDateVersion string // 最小日期版本
var isZip = false             // 是否压缩
var compressorType = "zlib"   // 压缩方式
var clinetOutFileType = "csv" // 客户端导出文件类型
var resourceDir = "resource/"
var fileNameTest = "_test" // 测试的文件延长

var jsFile = "jszip.min.js" // 单独处理的js文件

var jsZip = false // js文件打包

var waitgroup sync.WaitGroup // 记录进程处理结束

var logPath = "log/"
var FormatDate = "2006-01-02 15:04:05"
var FormatDay = "2006-01-02"
var FormatTime = "15:04:05"

func main() {
	var initTime = time.Now().Format(FormatDate)
	var initTimestamp = time.Now().Unix()
	var oldTimestamp = initTimestamp
	var calcTimestamp = initTimestamp
	items = make(map[string]*Item)
	currDateTime = time.Now().Format("20060102")
	if !checkFileIsExist(flaConfigPath) {
		// fmt.Println("当前目录缺少文件: ", flaConfigPath)
		ERROR("当前目录缺少文件: %s", flaConfigPath)
		return
	}
	if !checkFileIsExist(logPath) {
		if err := os.MkdirAll(logPath, 0777); err != nil {
			ERROR("目录不可创建 logPath %s", err)
		}
	}
	// if !checkFileIsExist("./nil.csv") {
	// 	ERROR("缺少文件nil.csv")
	// 	return
	// }
	readConfig(flaConfigPath)

	onDataDir := config.OnDataDir
	config.OnDataPath = change_path(onDataDir, config.OnDataPath)
	config.ClientInitialCsvPath = change_path(onDataDir, config.ClientInitialCsvPath)
	config.ClientSwfPath = change_path(onDataDir, config.ClientSwfPath)
	config.ManifestPath = change_path(onDataDir, config.ManifestPath)
	config.SettingPath = change_path(onDataDir, config.SettingPath)

	isZip = config.IsZip
	jsZip = config.JsZip
	clinetOutFileType = config.ClinetOutFileType
	initialPath = config.ClientInitialCsvPath
	goDataPath = config.GoDataPath
	compressorType = config.CompressorType

	goClinetDir = goDataPath + "../"

	endTime := time.Now().Format(FormatDate)
	calcTimestamp = time.Now().Unix()
	TimeNum := calcTimestamp - oldTimestamp
	oldTimestamp = calcTimestamp
	INFO("readConfig: %d 秒\t>> %v ", TimeNum, endTime)

	svn_up()
	calcTimestamp = time.Now().Unix()
	TimeNum = calcTimestamp - oldTimestamp
	oldTimestamp = calcTimestamp
	INFO("svn_up: %d 秒\t>> %v ", TimeNum, endTime)

	jsonFilePath := config.OnDataPath + config.ClientInitialJsonFile
	if config.OnDataPath == "" {
		jsonFilePath = initialPath + "../" + config.ClientInitialJsonFile
	}
	read_init_client(jsonFilePath)
	endTime = time.Now().Format(FormatDate)
	calcTimestamp = time.Now().Unix()
	TimeNum = calcTimestamp - oldTimestamp
	oldTimestamp = calcTimestamp
	INFO("read_init_client: %s %d 秒\t>> %v ", jsonFilePath, TimeNum, endTime)

	readCsvToItem()
	endTime = time.Now().Format(FormatDate)
	calcTimestamp = time.Now().Unix()
	TimeNum = calcTimestamp - oldTimestamp
	oldTimestamp = calcTimestamp
	INFO("readCsv: %d 秒\t>> %v ", TimeNum, endTime)
	goVersionPath = goDataPath + currDateVersion + "/"

	readDiffFilesToTargetDir(config.OnDataPath, goVersionPath)
	endTime = time.Now().Format(FormatDate)
	calcTimestamp = time.Now().Unix()
	TimeNum = calcTimestamp - oldTimestamp
	oldTimestamp = calcTimestamp
	INFO("readFiles: %d 秒\t>> %v ", TimeNum, endTime)
	if jsZip {
		read_js_client(goVersionPath)
		endTime = time.Now().Format(FormatDate)
		calcTimestamp = time.Now().Unix()
		TimeNum = calcTimestamp - oldTimestamp
		oldTimestamp = calcTimestamp
		INFO("read_js_client: %d 秒\t>> %v ", TimeNum, endTime)
	}

	writeNewCsv()
	endTime = time.Now().Format(FormatDate)
	calcTimestamp = time.Now().Unix()
	TimeNum = calcTimestamp - oldTimestamp
	TotalTimeNum := calcTimestamp - oldTimestamp
	fmt.Println("总运行时间时间: ", TotalTimeNum, "秒\t开始时间:", initTime, " >> ", endTime, "\r\n writeNewCsv:", TimeNum, "秒\t>> ", endTime)
}

// svn  up 目录
func svn_up() {
	svn_up_dir(config.OnDataPath)
	svn_up_dir(config.ClientSwfPath)
	// svn_up_dir(config.ClientInitialCsvPath)
	svn_up_dir(config.PlatformConfigJsonPath)
	svnManifestPath := string_remove(config.ManifestPath)
	svn_up_dir(svnManifestPath)
	// if err := CopyFile(svnManifestPath + "/index.html", goClinetDir + "/index.html");  err != nil{
	//     println("svn_up err",err)
	// }
}

// 更新目录内容
func svn_up_dir(pathDir string) {
	cmd := exec.Command("/bin/sh", "-c", `svn up`)
	cmd.Dir = string_remove(pathDir)
	out, err := cmd.CombinedOutput()
	if err != nil {
		ERROR("path %s: %s svn_up_dir err: %s", pathDir, err, string(out))
		os.Exit(3)
	}
	DEBUG("svn_up >>>: %s", pathDir)
}

// 提交文件
func svn_ci(pathDir string) {
	cmd := exec.Command("/bin/sh", "-c", "svn st"+pathDir+"| awk '{if ($1 == \"?\"||$1 == \"A\") {print $2} }' | xargs -r svn add")
	cmd.Dir = string_remove(pathDir)
	cmd.CombinedOutput()

	cmd = exec.Command("/bin/sh", "-c", "svn ci -m "+pathDir+" "+pathDir+" --force-log")
	out, err := cmd.CombinedOutput()
	if err != nil {
		ERROR("path %s: %s svn_ci err: %s", pathDir, err, string(out))
		os.Exit(2)
	}
	DEBUG("svn_ci >>>: %s", pathDir)
}

// 读取 上次 该目录的文件信息
func readCsvToItem() {
	csv_files_fath := config.CsvFilesPath
	currDateVersion = currDateTime + "01"
	minCurrDateVersion = currDateVersion
	var currDir = string_remove(csv_files_fath)
	versionPath = currDir + "/" + version_name

	// 客户端文件整合成一个文件
	// initialCsvPath := initialPath + initial_name
	// if checkFileIsExist(initialCsvPath) {
	//     var initialCsvBuffer bytes.Buffer
	//     initialCsvBytes, _ := ioutil.ReadFile(initialCsvPath)
	//     initialCsvLines := strings.Split(string(initialCsvBytes), "\r\n")
	//     var removeNum = 2
	//     // var totalInitialLen := len(initialCsvLines) - removeNum
	//     var totalInitialLen = 0
	//     // initialCsvBuffer.WriteString(strconv.Itoa(totalInitialLen))
	//     for i_num1, initialValue1 := range initialCsvLines {
	//         if removeNum <= i_num1 {
	//             if "" != initialValue1 {
	//                 totalInitialLen ++
	//             }
	//         }
	//     }

	//     bytesBuffer := bytes.NewBuffer([]byte{})
	//     binary.Write(bytesBuffer, binary.BigEndian, uint32(totalInitialLen))
	//     initialCsvBuffer.Write(bytesBuffer.Bytes())
	//      for i_num, initialValue := range initialCsvLines {
	//         if removeNum <= i_num {
	//             if "" != initialValue {
	//                 initialLine := strings.Split(initialValue, ",")
	//                 initialBytes, _ := ioutil.ReadFile(initialPath + initialLine[1])

	//                 bytesBuffer = bytes.NewBuffer([]byte{})
	//                 binary.Write(bytesBuffer, binary.BigEndian, uint32(len(initialLine[1])))
	//                 initialCsvBuffer.Write(bytesBuffer.Bytes())
	//                     // buf := bytes.NewBufferString(initialLine[1])
	//                     // initialCsvBuffer.Write(buf.Bytes())
	//                 initialCsvBuffer.WriteString(initialLine[1])
	//                 bytesBuffer = bytes.NewBuffer([]byte{})
	//                 binary.Write(bytesBuffer, binary.BigEndian, uint32(len(initialBytes)))
	//                 initialCsvBuffer.Write(bytesBuffer.Bytes())
	//                 initialCsvBuffer.Write(initialBytes)
	//             }
	//         }
	//     }
	//     ioutil.WriteFile(initialPath + "gamedata.csv", []byte(initialCsvBuffer.String()), 0666)
	//  }

	if !checkFileIsExist(csv_files_fath) || config.IsAll == true {
		return
	}

	if checkFileIsExist(versionPath) {
		versionBytes, _ := ioutil.ReadFile(versionPath)
		versionLines := strings.Split(string(versionBytes), "\r\n")
		var currDate1 = ""
		for _, versionValue := range versionLines {
			if "" != versionValue {
				line := strings.Split(versionValue, "\t")
				currDate1 = line[0]
			}
		}
		if currDate1 != "" {
			currDate2 := strings.Split(currDate1, ":")
			currDate3 := currDate2[1]
			if currDate3[:8] == currDateTime {
				currDateVersion = currDateTime + change_num(currDate3[8:])
			}
		}
	}

	csv_bytes, _ := ioutil.ReadFile(csv_files_fath)
	lines := strings.Split(string(csv_bytes), "\r\n")
	for _, value := range lines {
		if "" != value {
			line := strings.Split(value, ",")
			if minCurrDateVersion > line[1] {
				minCurrDateVersion = line[1]
			}
			items[line[2]] = &Item{line[0], line[1], line[2]}
		}
	}
	INFO("当前最小日期版本 %s", minCurrDateVersion)

}

// 读取客户端 初始化文件压缩
func read_init_client(clientInitialJsonPath string) {
	// var initialCsvBuffer bytes.Buffer
	// enc := mahonia.NewEncoder("GBK")
	clientInitialBytes, _ := ioutil.ReadFile(clientInitialJsonPath)
	err := json.Unmarshal(clientInitialBytes, &clienJson)
	if err != nil {
		fmt.Println(err)
	}
	var clienJsonStr string
	for _, clienJsonGroups := range clienJson.Groups {
		if clienJsonGroups.Name == "preloadJson" {
			clienJsonStr = clienJsonGroups.Keys
		}
	}

	clienJsonStr = strings.Replace(clienJsonStr, "_json", ".json", -1)

	// enc := mahonia.NewEncoder("UTF-8") // 转成utf8编码

	// gamedataFile := initialPath + "../gamedata" + zibSuffix
	// buf, _ := os.Create(gamedataFile)
	// w := zip.NewWriter(buf)

	// var csvFileBuffer bytes.Buffer
	// csvFileBuffer.WriteString("{")
	clienJsonList := strings.Split(clienJsonStr, ",")
	// clienJsonLen := len(clienJsonList) - 1

	// // filepath.Walk(path, func(path1 string, file os.FileInfo, err error) error {
	// for clienJsonIndex, fileNameInfo := range clienJsonList {
	// 	// if ( file == nil ) {return err}
	// 	// if file.IsDir() {return nil}
	// 	// if strings.Index(path1, ".svn") != -1 { return nil}          // 过滤svn文件
	// 	// if strings.Index(path1, ".json") == -1 { return nil}          // 过滤不是jso文件
	// 	// var fileNameInfo = file.Name()
	// 	path1 := initialPath + fileNameInfo
	// 	initialBytes, err := ioutil.ReadFile(path1)
	// 	if err != nil {
	// 		// fmt.Println("ioutil.ReadFile :", err)
	// 		ERROR("读取客户端 %s  err %s", path1, err)
	// 		continue
	// 	}
	// 	initialStr := string(initialBytes)
	// 	initialStr = enc.ConvertString(initialStr)
	// 	initialStr = regexp.MustCompile(`\r`).ReplaceAllString(initialStr, "")
	// 	initialStr = regexp.MustCompile(`\n`).ReplaceAllString(initialStr, "")
	// 	initialStr = regexp.MustCompile(`\t`).ReplaceAllString(initialStr, "")
	// 	initialStr = regexp.MustCompile(` `).ReplaceAllString(initialStr, "")

	// 	csvFileBuffer.WriteString("\""+get_remove_Ext(fileNameInfo) + "\":")
	// 	if clienJsonLen == clienJsonIndex {
	// 		csvFileBuffer.WriteString(initialStr + "}")
	// 	} else {
	// 		csvFileBuffer.WriteString(initialStr + ",")
	// 	}

	// 	output := []byte(initialStr)
	// 	f, err := w.Create(fileNameInfo)
	// 	if err != nil {
	// 		ERROR("Create fileNameInfo %s  err %s", fileNameInfo, err)
	// 	}
	// 	_, err = f.Write(output)
	// 	if err != nil {
	// 		ERROR("Write fileNameInfo %s  err %s", fileNameInfo, err)
	// 	}

	// 	// return nil
	// 	// })
	// }
	// clientCsvPath := initialPath + "../gamedata.json"
	// ioutil.WriteFile(clientCsvPath, []byte(csvFileBuffer.String()), 0666)
	// err = w.Close()
	// if err != nil {
	// 	ERROR("Close filse err %s", err)
	// 	os.Exit(4)
	// }
	// svn_ci(gamedataFile)
	gamedataPath := initialPath + "../"
	create_gamedata(initialPath, gamedataPath, "", clienJsonList)
	err = filepath.Walk(initialPath, func(platformGameDataPath string, file os.FileInfo, err error) error {
		if file == nil {
			return err
		}
		if file.IsDir() == false {
			return nil
		}
		if strings.Index(platformGameDataPath, ".svn") != -1 {
			return nil
		} // 过滤svn文件
		if initialPath == platformGameDataPath {
			return nil
		} // 过滤当前根级目录
		if strings.Index(platformGameDataPath, "plan_csv") != -1 {
			return nil
		} // 过滤plan_csv
		if strings.Index(platformGameDataPath, "server_csv") != -1 {
			return nil
		} // 过滤server_csv
		var prefixGameData = file.Name()
		create_gamedata(platformGameDataPath+"/", gamedataPath, prefixGameData+"_", clienJsonList)
		return nil
	})
	if err != nil {
		ERROR("create_gamedata %s", err)
		os.Exit(4)
	}
}

// 创建xx_gamedata文件
func create_gamedata(jsonPath, gamedataPath, prefixGameData string, clienJsonList []string) {

	INFO("创建xx_gamedata文件 %s =>%s =>%s", jsonPath, gamedataPath, prefixGameData)
	enc := mahonia.NewEncoder("UTF-8") // 转成utf8编码
	gamedataFile := gamedataPath + prefixGameData + "gamedata" + zibSuffix
	buf, _ := os.Create(gamedataFile)
	w := zip.NewWriter(buf)
	// var csvFileBuffer bytes.Buffer
	// csvFileBuffer.WriteString("{")
	// clienJsonList := strings.Split(clienJsonStr, ",")
	// clienJsonLen := len(clienJsonList) - 1

	// filepath.Walk(path, func(path1 string, file os.FileInfo, err error) error {
	for _, fileNameInfo := range clienJsonList {
		// if ( file == nil ) {return err}
		// if file.IsDir() {return nil}
		// if strings.Index(path1, ".svn") != -1 { return nil}          // 过滤svn文件
		// if strings.Index(path1, ".json") == -1 { return nil}          // 过滤不是jso文件
		// var fileNameInfo = file.Name()
		path1 := jsonPath + fileNameInfo
		initialBytes, err := ioutil.ReadFile(path1)
		if err != nil {
			// fmt.Println("ioutil.ReadFile :", err)
			ERROR("读取客户端%s  %s  err %s", jsonPath, path1, err)
			continue
		}
		initialStr := string(initialBytes)
		initialStr = enc.ConvertString(initialStr)
		initialStr = regexp.MustCompile(`\r`).ReplaceAllString(initialStr, "")
		initialStr = regexp.MustCompile(`\n`).ReplaceAllString(initialStr, "")
		initialStr = regexp.MustCompile(`\t`).ReplaceAllString(initialStr, "")
		//initialStr = regexp.MustCompile(` `).ReplaceAllString(initialStr, "")

		// csvFileBuffer.WriteString("\""+get_remove_Ext(fileNameInfo) + "\":")
		// if clienJsonLen == clienJsonIndex {
		// 	csvFileBuffer.WriteString(initialStr + "}")
		// } else {
		// 	csvFileBuffer.WriteString(initialStr + ",")
		// }

		output := []byte(initialStr)
		f, err := w.Create(fileNameInfo)
		if err != nil {
			ERROR("Create fileNameInfo %s  err %s", fileNameInfo, err)
		}
		_, err = f.Write(output)
		if err != nil {
			ERROR("Write fileNameInfo %s  err %s", fileNameInfo, err)
		}

		// return nil
		// })
	}
	// clientCsvPath := gamedataPath + prefixGameData + "gamedata.json"
	// ioutil.WriteFile(clientCsvPath, []byte(csvFileBuffer.String()), 0666)
	err := w.Close()
	if err != nil {
		ERROR("Close filse err %s", err)
		os.Exit(4)
	}
}

// 读取客户端 js文件压缩
func read_js_client(goVersionPath string) {
	if err1 := os.MkdirAll(goVersionPath, 0755); err1 != nil {
		ERROR("文件创建失败 path%s  err %s ", goVersionPath, err1)
		os.Exit(5)
	}
	jsClientZipName = "game" + zibSuffix
	gamedataFile := goVersionPath + jsClientZipName
	buf, _ := os.Create(gamedataFile)
	w := zip.NewWriter(buf)

	filepath.Walk(config.ClientSwfPath, func(path1 string, file os.FileInfo, err error) error {
		// for _, fileNameInfo := range strings.Split(clienJsonStr, ",") {
		if file == nil {
			return nil
		}
		if file.IsDir() {
			return nil
		}
		if strings.Index(path1, ".svn") != -1 {
			return nil
		} // 过滤svn文件
		if strings.Index(path1, jsFile) != -1 {
			return nil
		} // 过滤不是jso文件
		if strings.Index(path1, ".js") == -1 {
			return nil
		} // 只处理js文件
		var fileNameInfo = file.Name()
		// path1 := initialPath + fileNameInfo
		output, err := ioutil.ReadFile(path1)
		if err != nil {
			ERROR("读取客户端 %s  err %s", path1, err)
			return nil
			// continue
		}
		f, err := w.Create(fileNameInfo)
		if err != nil {
			ERROR("Create fileNameInfo %s  err %s", fileNameInfo, err)
			os.Exit(5)
		}
		_, err = f.Write(output)
		if err != nil {
			// fmt.Println("compressor_zip Write error :", err)
			ERROR("Write fileNameInfo %s  err %s", fileNameInfo, err)
			os.Exit(5)
		}
		return nil
	})
	// }
	err := w.Close()
	if err != nil {
		ERROR("Close filse err %s", err)
		os.Exit(4)
	}
	if err := CopyFile(config.ClientSwfPath+jsFile, goVersionPath+jsFile); err != nil {
		println("svn_up err", err)
	}
}

// 写出新的 目录的文件信息
func writeNewCsv() {
	manifestPath := config.ManifestPath
	settingPath := config.SettingPath
	filesListCsvPath := config.CsvFilesPath
	goServerVersionPath := config.GoServerVersionPath
	// var versionFile *os.File
	NewGoCsvFilesPath := goDataPath + goCsvFilesPath // 存放csv 版本目录
	var currDir = string_remove(NewGoCsvFilesPath)
	var clientCsvPath = currDir + "/" + currDateVersion + "." + clinetOutFileType
	var filesListBuff bytes.Buffer
	// filesListBuff.WriteString("文件的MD5值,版本,路径\r\n")
	var clientCsvBuffer bytes.Buffer
	if clinetOutFileType == "json" {
		clientCsvBuffer.WriteString("{\r\n")
	} else if clinetOutFileType == "csv" {
		clientCsvBuffer.WriteString("//路径,版本\r\nFilePath,Version\r\n")
	}
	var clientJsonCount = 0 // 记录条数
	for _, value := range items {
		if minCurrDateVersion < value.Version {
			if clinetOutFileType == "json" {
				if clientJsonCount > 0 {
					clientCsvBuffer.WriteString(",\r\n\t\"")
				} else {
					clientCsvBuffer.WriteString("\t\"")
				}
				clientCsvBuffer.WriteString(value.Path)
				clientCsvBuffer.WriteString("\":")
				clientCsvBuffer.WriteString(value.Version)
				clientJsonCount++

			} else if clinetOutFileType == "csv" {
				clientCsvBuffer.WriteString(value.Path)
				clientCsvBuffer.WriteString(",")
				clientCsvBuffer.WriteString(value.Version)
				clientCsvBuffer.WriteString("\r\n")
			}
		}

		filesListBuff.WriteString(value.MD5)
		filesListBuff.WriteString(",")
		filesListBuff.WriteString(value.Version)
		filesListBuff.WriteString(",")
		filesListBuff.WriteString(value.Path)
		filesListBuff.WriteString("\r\n")
	}
	if !checkFileIsExist(currDir) {
		if err := os.MkdirAll(currDir, 0755); err != nil {
			// println(err)
			// fmt.Println("版本目录不可创建")
			ERROR("版本目录不可创建 err %s", err)
		}
	}
	if clinetOutFileType == "json" {
		clientCsvBuffer.WriteString("\r\n}")
	}
	ioutil.WriteFile(clientCsvPath, []byte(clientCsvBuffer.String()), 0666)
	ioutil.WriteFile(filesListCsvPath, []byte(filesListBuff.String()), 0666)
	if isZip == true {
		compressorFile(clientCsvPath, clientCsvPath)
	}

	ioutil.WriteFile(versionPath, []byte("当前最新版本:"+currDateVersion+"\t操作时间:"+time.Now().Format("2006-01-02 15:04:05")+"\t初始版本:"+minCurrDateVersion+"\r\n"), 0666)
	if goServerVersionPath != "" {
		ioutil.WriteFile(goServerVersionPath+version_name, []byte(currDateVersion+":"+minCurrDateVersion), 0666)
	}

	manifestFileName := path.Base(manifestPath) //获取文件名带后缀
	var manifestStr = ""
	var manifestStrTest = ""
	if jsZip {
		manifestStr = "{\"initial\": [\"resource/" + currDateVersion + "/" + jsFile + "\"],\n\"game\": [\"resource/" + currDateVersion + "/" + jsClientZipName + "\"]}"
		manifestStrTest = "{\"initial\": [\"../resource/" + currDateVersion + "/" + jsFile + "\"],\n\"game\": [\"../resource/" + currDateVersion + "/" + jsClientZipName + "\"]}"
	} else {
		oldManifestBety, _ := ioutil.ReadFile(manifestPath)
		manifestStr = string(oldManifestBety)
		manifestStrTest = string(oldManifestBety)

		filepath.Walk(config.ClientSwfPath, func(clientSwfPath1 string, file os.FileInfo, err error) error {
			if file == nil {
				return err
			}
			if file.IsDir() {
				return nil
			}
			if strings.Index(clientSwfPath1, ".svn") != -1 {
				return nil
			} // 过滤svn文件
			if strings.Index(clientSwfPath1, ".js") == -1 {
				return nil
			} // 只处理js文件
			// swfFileName := path.Base(SwfPath) //获取文件名带后缀
			swfFileName := file.Name() //获取文件名带后缀
			CopyFile(clientSwfPath1, goVersionPath+swfFileName)
			manifestStr = regexp.MustCompile(`"(.*)`+swfFileName+`"`).ReplaceAllString(manifestStr, "\""+resourceDir+currDateVersion+"/"+swfFileName+"\"")
			manifestStrTest = regexp.MustCompile(`"(.*)`+swfFileName+`"`).ReplaceAllString(manifestStrTest, "\"../"+resourceDir+currDateVersion+"/"+swfFileName+"\"")
			return nil
		})
		// for _, SwfPath := range clientSwfPathList {
		//     swfFileName := path.Base(SwfPath) //获取文件名带后缀
		//     oldManifestStr = regexp.MustCompile(`"(.*)`+swfFileName+`"`).ReplaceAllString(oldManifestStr, "\"resource/" + currDateVersion + "/"+ swfFileName + "\"")
		// }
	}
	settingFileName := path.Base(settingPath) //获取文件名带后缀
	oldSettingBety, _ := ioutil.ReadFile(settingPath)
	settingStr := string(oldSettingBety)
	settingStr = regexp.MustCompile(`"versions"\s*:(.*)"`).ReplaceAllString(settingStr, "\"versions\":\""+currDateVersion+"\"")
	settingStr = regexp.MustCompile(`"firstversions"\s*:(.*)"`).ReplaceAllString(settingStr, "\"firstversions\":\""+minCurrDateVersion+"\"")
	settingStr = regexp.MustCompile(`"isdebug"\s*:\s*\w`).ReplaceAllString(settingStr, "\"isdebug\":0")

	manifestPathDir := string_remove(manifestPath) + "/"

	filepath.Walk(config.PlatformConfigJsonPath, func(PlatformConfigJsonPath1 string, file os.FileInfo, err error) error {
		if file == nil {
			return err
		}
		if file.IsDir() {
			return nil
		}
		// if strings.Index(PlatformConfigJsonPath1, ".svn") != -1 {return nil} // 过滤svn文件
		if strings.Index(PlatformConfigJsonPath1, ".json") == -1 {
			return nil
		} // 只处理文件
		readPlatformConfig(PlatformConfigJsonPath1)
		FileName := get_remove_Ext(file.Name())
		platformPath := goClinetDir + FileName + "/"
		platformResourcePath := goClinetDir + FileName + "/resource/"

		platformPathTest := goClinetDir + FileName + fileNameTest + "/"
		platformResourcePathTest := goClinetDir + FileName + fileNameTest + "/resource/"

		if platformConfig.IsPack != true && checkFileIsExist(platformResourcePath) {
			return nil
		}
		var resourceCdn = ""
		var testResourceCdn = "../../" + resourceDir
		if platformConfig.Cdn != "" {
			resourceCdn = platformConfig.Cdn
			if resourceCdn == strings.TrimSuffix(resourceCdn, "/") {
				resourceCdn += "/"
			}
			testResourceCdn = resourceCdn + resourceDir
		}
		var readIndexHtml = "index.html"
		if platformConfig.Index_html != "" {
			readIndexHtml = platformConfig.Index_html
			platformConfig.Index_html = ""
		}
		var channelStr = ""
		if platformConfig.Channel != "" {
			channelStr = platformConfig.Channel
			platformConfig.Channel = ""
		}
		settingStr = regexp.MustCompile(`"cdn":(.*)"`).ReplaceAllString(settingStr, "\"cdn\":\""+resourceCdn+resourceDir+"\"")
		settingStr = regexp.MustCompile(`"channel":(.*)"`).ReplaceAllString(settingStr, "\"channel\":\""+channelStr+"\"")
		settingStr1 := regexp.MustCompile(`"platform_id"\s*:(.*)"`).ReplaceAllString(settingStr, "\"platform_id\":\""+platformConfig.Platform_id+"\"")
		settingStr1 = regexp.MustCompile(`"server_list_url_recent"\s*:(.*)"`).ReplaceAllString(settingStr1, "\"server_list_url_recent\":\""+platformConfig.Server_list_url_recent+"\"")
		settingStr1 = regexp.MustCompile(`"server_list_url_all"\s*:(.*)"`).ReplaceAllString(settingStr1, "\"server_list_url_all\":\""+platformConfig.Server_list_url_all+"\"")
		settingStr1 = regexp.MustCompile(`"is_product"\s*:(.*)"`).ReplaceAllString(settingStr1, "\"is_product\":\""+platformConfig.Is_product+"\"")

		settingStrTest := regexp.MustCompile(`"cdn":(.*)"`).ReplaceAllString(settingStr1, "\"cdn\":\""+testResourceCdn+"\"")
		settingStrTest = regexp.MustCompile(`"channel":(.*)"`).ReplaceAllString(settingStrTest, "\"channel\":\""+channelStr+"\"")

		if !checkFileIsExist(platformResourcePath) {
			if err = os.MkdirAll(platformResourcePath, 0755); err != nil {
				ERROR("版本目录不可创建 path %s err %s", platformResourcePath, err)
			}
		}
		if !checkFileIsExist(platformResourcePathTest) {
			if err = os.MkdirAll(platformResourcePathTest, 0755); err != nil {
				ERROR("版本目录不可创建 Testpath %s err %s", platformResourcePathTest, err)
			}
		}

		ioutil.WriteFile(platformPath+manifestFileName, []byte(manifestStr), 0666)
		ioutil.WriteFile(platformPathTest+manifestFileName, []byte(manifestStrTest), 0666)
		ioutil.WriteFile(platformResourcePath+settingFileName, []byte(settingStr1), 0666)
		ioutil.WriteFile(platformResourcePathTest+settingFileName, []byte(settingStrTest), 0666)

		var indexRes = "index_res"
		CopyDir(manifestPathDir+indexRes, platformPath+indexRes, ".svn")
		CopyDir(manifestPathDir+indexRes, platformPathTest+indexRes, ".svn")

		var indexHtml = "index.html"
		changeIndexHtml, _ := ioutil.ReadFile(manifestPathDir + readIndexHtml)
		changeIndexHtmlStr1 := string(changeIndexHtml)
		changeIndexHtmlStr := changeIndexHtmlStr1
		testChangeIndexHtmlStr := changeIndexHtmlStr1
		if platformConfig.Index_remove_version == false {
			changeIndexHtmlStr = regexp.MustCompile(`var\s*manifestData\s*=(.*)`).ReplaceAllString(changeIndexHtmlStr1, "var manifestData = "+manifestStr)
			changeIndexHtmlStr = regexp.MustCompile(`var\s*settingData\s*=(.*)`).ReplaceAllString(changeIndexHtmlStr, "var settingData = "+settingStr1)

			testChangeIndexHtmlStr = regexp.MustCompile(`var\s*manifestData\s*=(.*)`).ReplaceAllString(changeIndexHtmlStr1, "var manifestData = "+manifestStrTest)
			testChangeIndexHtmlStr = regexp.MustCompile(`var\s*settingData\s*=(.*)`).ReplaceAllString(testChangeIndexHtmlStr, "var settingData = "+settingStrTest)
		}
		ioutil.WriteFile(platformPath+indexHtml, []byte(changeIndexHtmlStr), 0666)
		ioutil.WriteFile(platformPathTest+indexHtml, []byte(testChangeIndexHtmlStr), 0666)

		// if err = CopyFile(manifestPathDir + indexHtml , platformPath + indexHtml); err != nil {
		// 	ERROR("CopyFile %s platformPath %s err %s", indexHtml, platformPath, err)
		// 			// println("platformPath CopyFile index.html err", err)
		// 	}
		// if err = CopyFile(manifestPathDir + indexHtml, platformPathTest + indexHtml); err != nil {
		// 	ERROR("CopyFile %s platformPathTest %s err %s", indexHtml, platformPathTest, err)
		// 	// println("platformPathTest CopyFile index.html err", err)
		// }
		if err = CopyFile(config.OnDataPath+"/initialize.res.json", platformResourcePath+"/initialize.res.json"); err != nil {
			ERROR("CopyFile initialize.res.json platformResourcePath %s err %s", platformResourcePath, err)
		}
		if err = CopyFile(config.OnDataPath+"/initialize.res.json", platformResourcePathTest+"/initialize.res.json"); err != nil {
			ERROR("CopyFile initialize.res.json platformResourcePathTest %s err %s", platformResourcePathTest, err)
		}
		return nil
	})
	configBytes, _ := ioutil.ReadFile(flaConfigPath)
	configStr := string(configBytes)
	configStr = regexp.MustCompile(`"IsAll(.*)`).ReplaceAllString(configStr, "\"IsAll\":false,")
	ioutil.WriteFile(flaConfigPath, []byte(configStr), 0666)
	logFileWrite("当前最新版本:" + currDateVersion + ",\t初始版本:" + minCurrDateVersion)
}

// 比对该目录下的文件是否相同
func readDiffFilesToTargetDir(onDir string, dest_dir string) {
	fmt.Println("readFiles  onDir: ", onDir)
	if err1 := os.MkdirAll(dest_dir, 0755); err1 != nil {
		ERROR("文件创建失败 path%s  err %s ", dest_dir, err1)
	}
	if onDir == "" {
		return
	}
	speedRendFileLoop(onDir, dest_dir)
	// for _, SwfPath := range clientSwfPathList {
	//     swfFileName := path.Base(SwfPath) //获取文件名带后缀
	//     CopyFile(SwfPath, dest_dir + swfFileName)
	// }

	// swfFileName := path.Base(SwfPath) //获取文件名带后缀
	// // swfPathSuffix := path.Ext(SwfPath) //获取运行文件后缀
	// // CopyFile(SwfPath, dest_dir + currDateVersion + swfPathSuffix)
	// CopyFile(SwfPath, dest_dir + swfFileName)
}

// 快速处理线程
func speedRendFileLoop(path string, dest_dir string) {
	var pathLen = len(path)
	// runtime.GOMAXPROCS(runtime.NumCPU())
	var calcTime = time.Now().Unix()
	var toTime = time.Now().Unix()
	var toNum = 0
	var topNum = 0
	var minNum = 9999999
	var fileTotleNum = 0 // 文件总数据
	var calcNumber = 1
	var fileBufferStr bytes.Buffer
	var fileBuffer bytes.Buffer
	pathStrRecord := ""

	err := filepath.Walk(path, func(path string, file os.FileInfo, err error) error {
		if file == nil {
			return err
		}
		if file.IsDir() {
			return nil
		}
		if strings.Index(path, ".svn") != -1 {
			return nil
		} // 过滤svn文件
		if strings.Index(path, ".psd") != -1 {
			return nil
		} // 过滤psd文件
		if pathStrRecord == "" {
			pathStrRecord = path
			fileBufferStr.WriteString(path)
		} else {
			fileBufferStr.WriteString("," + path)
		}
		return nil
	})
	filePathStr := fileBufferStr.String()
	if filePathStr == "" {
		INFO(">>没有可处理数据<<")
		return
	}
	ftpStrList := strings.Split(filePathStr, ",")
	ItemLen := len(ftpStrList)
	INFO(">>处理数据开始<<:%d", ItemLen)
	LoopNum := runtime.NumCPU() * config.CpuDouble
	if LoopNum >= ItemLen {
		LoopNum = ItemLen
	}
	jobs := make(chan int, ItemLen)           //Job为100个可以传递int类型的channel
	resultsItem := make(chan string, LoopNum) // 当前通道的文件

	// 添加全部任务
	for j := 0; j < ItemLen; j++ {
		jobs <- j //向Jobs添加任务： 向Channel中写入数据， 传递的数据类型为int
	}
	//开启三个线程，说明线程池中只有三个线程， 在实际情况下可以动态设置开启线程数量
	for LoopI := 1; LoopI <= LoopNum; LoopI++ {
		go workerItem(jobs, resultsItem, ftpStrList, dest_dir, pathLen) // ??这里并没有用到dest_dir
	}
	// fileBufferStr.Reset()
	close(jobs)
	toNum = 0
	calcNumber = 1
	pathStrRecord = ""
	calcTime = time.Now().Unix()
	for settleNum := 0; settleNum < ItemLen; settleNum++ {
		strItem := <-resultsItem //从Channel中读取数据, 输出的数据类型为 string
		if strItem != "" {
			strItemList := strings.Split(strItem, ",")
			strItemLen := len(strItemList)
			if strItemLen == 3 {
				md5 := strItemList[0]
				nextPath := strItemList[1]
				onPath := strItemList[2]
				// fmt.Println(ItemLen-settleNum, "\t:",onPath)
				item, ok := items[nextPath]
				if ok {
					//差异
					if md5 != item.MD5 {
						item.MD5 = md5
						item.Version = currDateVersion
						if pathStrRecord == "" {
							pathStrRecord = onPath + "," + dest_dir + nextPath
							fileBuffer.WriteString(pathStrRecord)
						} else {
							fileBuffer.WriteString("\r\n" + onPath + "," + dest_dir + nextPath)
						}
					}
				} else {
					//新增
					items[nextPath] = &Item{md5, currDateVersion, nextPath}
					if pathStrRecord == "" {
						pathStrRecord = onPath + "," + dest_dir + nextPath
						fileBuffer.WriteString(pathStrRecord)
					} else {
						fileBuffer.WriteString("\r\n" + onPath + "," + dest_dir + nextPath)
					}
				}

				//??? 缺少一种情况， files.csv中有的而在trunk没有的情况 ，即是否需要删除 delete items[nextPath]剩下的既是这种情况
			}
		}
		toTime = time.Now().Unix()
		if (toTime - calcTime) > 10 {
			if topNum < toNum {
				topNum = toNum
			}
			if toNum < minNum && 0 < toNum {
				minNum = toNum
			}
			INFO("第 %d 个10s处理:%d 条\t处理数据总数:%d", calcNumber, toNum, settleNum)
			calcNumber++
			calcTime = toTime
			toNum = 0
		}
		toNum++
		fileTotleNum++
	}
	if toNum > 0 {
		INFO("第 %d 个10s处理了:%d 条\t处理数据总数:%d", calcNumber, toNum, fileTotleNum)
	}

	filePathStr = fileBuffer.String()
	if filePathStr == "" {
		INFO(">>处理数据结束<<")
		return
	}
	ftpStrList = strings.Split(filePathStr, "\r\n")
	Len := len(ftpStrList)
	INFO("====开始处理版本文件====:%d", Len)
	LoopNum = runtime.NumCPU() * config.CpuDouble
	if LoopNum >= Len {
		LoopNum = Len
	}

	jobs = make(chan int, Len)         //Job为100个可以传递int类型的channel
	results := make(chan int, LoopNum) // 当前通道的文件

	// 添加全部任务
	for j := 0; j < Len; j++ {
		jobs <- j //向Jobs添加任务： 向Channel中写入数据， 传递的数据类型为int
	}
	//开启三个线程，说明线程池中只有三个线程， 在实际情况下可以动态设置开启线程数量
	for LoopI := 1; LoopI <= LoopNum; LoopI++ {
		// go worker(jobs, results, ftpStrList, dest_dir, pathLen)
		go worker(jobs, results, ftpStrList)
	}

	//  //关闭Channel
	close(jobs)
	toNum = 0
	calcNumber = 1
	calcTime = time.Now().Unix()
	for settleNum := 0; settleNum < Len; settleNum++ {
		<-results //从Channel中读取数据, 输出的数据类型为 string
		// fmt.Println(Len-settleNum, "\t:", path1)
		toTime = time.Now().Unix()
		if (toTime - calcTime) > 10 {
			if topNum < toNum {
				topNum = toNum
			}
			if toNum < minNum && 0 < toNum {
				minNum = toNum
			}
			INFO("第 %d 个10s处理:%d 个文件\t文件剩余数:%d", calcNumber, toNum, Len-settleNum)
			calcNumber++
			calcTime = toTime
			toNum = 0
		}
		toNum++
	}
	if err != nil {
		ERROR("speedRendFileLoop error %s", err)
	}
	INFO("10s处理最高%d 最低:%d\t操作文件数:%d\t总共文件数:%d", topNum, minNum, Len, fileTotleNum)
	INFO("快速处理线程方式结束")
}

func workerItem(jobs <-chan int, results chan<- string, ftpStrList []string, dest_dir string, pathLen int) {
	for j := range jobs {
		results <- speedRendItem(ftpStrList[j], dest_dir, pathLen)
	}
}
func worker(jobs <-chan int, results chan<- int, ftpStrList []string) {
	for j := range jobs {
		speedRendFile(ftpStrList[j])
		results <- j
	}
}

// 处理文件数据
func speedRendItem(pathStr, dest_dir string, pathLen int) (str string) {
	if pathStr == "" {
		return ""
	}
	var onPath = strings.Replace(pathStr, "\\", "/", -1) // println(nextPath1)
	var nextPath = string([]byte(onPath)[pathLen:])
	md5 := readMD5(pathStr)
	return md5 + "," + nextPath + "," + onPath
}

// 处理文件
func speedRendFile(pathStr string) {
	pathStrList := strings.Split(pathStr, ",")
	if len(pathStrList) < 2 {
		ERROR("pathStr最少2位数组:" + pathStr)
		return
	}
	onPath := pathStrList[0]
	dest_dir := pathStrList[1]
	loop_md5(onPath, dest_dir)
}

// 正常方式
func commonRendFile(path string, dest_dir string) {
	var len1 = len(path)
	runtime.GOMAXPROCS(runtime.NumCPU())
	var calcTime = time.Now().Unix()
	var toTime = time.Now().Unix()
	var toNum = 0
	var topNum = 0
	var minNum = 9999999
	var totleNum = 0
	var calcNumber = 1
	var calc_count = 0 // 计算每次处理的数数

	err := filepath.Walk(path, func(path string, file os.FileInfo, err error) error {
		if file == nil {
			return err
		}
		if file.IsDir() {
			return nil
		}
		if strings.Index(path, ".svn") != -1 {
			return nil
		} // 过滤svn文件
		toTime = time.Now().Unix()
		if (toTime - calcTime) > 10 {
			if topNum < toNum {
				topNum = toNum
			}
			if toNum < minNum && 0 < toNum {
				minNum = toNum
			}
			// fmt.Println(calcNumber, "个 10s 处理了:", toNum, " 》》条数据, 处理了数据:", totleNum)
			INFO("%d 个 10s 处理了:%d 》》条数据, 处理了数据:%d", calcNumber, toNum, totleNum)
			calcNumber++
			calcTime = toTime
			toNum = 0
		}
		toNum++
		totleNum++
		// copy到别一个目录中
		var onPath = strings.Replace(path, "\\", "/", -1) // println(nextPath1)
		var nextPath = string([]byte(onPath)[len1:])
		item, ok := items[nextPath]
		md5 := readMD5(path)
		if ok {
			if md5 != item.MD5 {
				calc_count++
				if calc_count%5 == 1 {
					loop_md5(onPath, dest_dir+nextPath)
				} else {
					waitgroup.Add(1) //每创建一个goroutine，就把任务队列中任务的数量+1
					go loop_md5_2(onPath, dest_dir+nextPath, true)
				}
				item.MD5 = md5
				item.Version = currDateVersion
			}
		} else {
			calc_count++
			if calc_count%5 == 1 {
				loop_md5(onPath, dest_dir+nextPath)
			} else {
				waitgroup.Add(1) //每创建一个goroutine，就把任务队列中任务的数量+1
				go loop_md5_2(onPath, dest_dir+nextPath, true)
			}
			items[nextPath] = &Item{md5, currDateVersion, nextPath}
		}
		return nil
	})

	if err != nil {
		// fmt.Printf("error: %v\n", err)
		ERROR("commonRendFile error %s", err)
	}
	INFO("混合进程 10s处理 最高%d 》》最低:%d  》》平均:%d  》》操作文件数%d", topNum, minNum, totleNum/calcNumber, calc_count)
	// fmt.Println("混合进程 10s处理 最高", topNum, " 》》最低", minNum, " 》》平均", totleNum/calcNumber, " 》》操作文件数", calc_count)
	// fmt.Println("混合进程方式等待结束 .......")
	INFO("混合进程方式等待结束 .......")
	waitgroup.Wait() //Wait()这里会发生阻塞，直到队列中所有的任务结束就会解除阻塞
	INFO("混合进程方式结束")
}

// 多进程方式
func commonRendFile2(path string, dest_dir string) {
	var len1 = len(path)
	runtime.GOMAXPROCS(runtime.NumCPU())

	var calcTime = time.Now().Unix()
	var toTime = time.Now().Unix()
	var toNum = 0
	var topNum = 0
	var minNum = 9999999
	var totleNum = 0
	var calcNumber = 1
	var calc_count = 0 // 计算每次处理的数数
	err := filepath.Walk(path, func(path string, file os.FileInfo, err error) error {
		if file == nil {
			return err
		}
		if file.IsDir() {
			return nil
		}
		if strings.Index(path, ".svn") != -1 {
			return nil
		} // 过滤svn文件
		toTime = time.Now().Unix()
		if (toTime - calcTime) > 10 {
			if topNum < toNum {
				topNum = toNum
			}
			if toNum < minNum && 0 < toNum {
				minNum = toNum
			}
			// fmt.Println(calcNumber, "个 10s 处理了:", toNum, " 》》条数据, 处理了数据:", totleNum)
			INFO("%d 个 10s 处理了:%d 》》条数据, 处理了数据:%d", calcNumber, toNum, totleNum)
			calcNumber++
			calcTime = toTime
			toNum = 0
		}
		toNum++
		totleNum++
		// copy到别一个目录中
		var onPath = strings.Replace(path, "\\", "/", -1) // println(nextPath1)
		var nextPath = string([]byte(onPath)[len1:])
		// num := 0
		//  fmt.Println(" >>nextPath:", nextPath)
		item, ok := items[nextPath]
		md5 := readMD5(path)
		if ok {
			if md5 != item.MD5 {
				calc_count++
				waitgroup.Add(1) //每创建一个goroutine，就把任务队列中任务的数量+1
				go loop_md5_2(onPath, dest_dir+nextPath, true)
				item.MD5 = md5
				item.Version = currDateVersion
			}
		} else {
			calc_count++
			waitgroup.Add(1) //每创建一个goroutine，就把任务队列中任务的数量+1
			go loop_md5_2(onPath, dest_dir+nextPath, true)
			items[nextPath] = &Item{md5, currDateVersion, nextPath}
		}
		return nil
	})
	if err != nil {
		// fmt.Printf("error: %v\n", err)
		ERROR("commonRendFile error %s", err)
	}

	INFO("混合进程 10s处理 最高%d 》》最低:%d  》》平均:%d  》》操作文件数%d", topNum, minNum, totleNum/calcNumber, calc_count)
	INFO("混合进程方式等待结束 .......")
	waitgroup.Wait() //Wait()这里会发生阻塞，直到队列中所有的任务结束就会解除阻塞
	INFO("混合进程方式结束")
	// fmt.Println("多进程 10s处理 最高", topNum, " 》》最低", minNum, " 》》平均", totleNum/calcNumber)
	// fmt.Println("总共处理文件:", totleNum, "个, 多进程方式等待结束 .......")
	// waitgroup.Wait() //Wait()这里会发生阻塞，直到队列中所有的任务结束就会解除阻塞
	// fmt.Println("多进程方式结束")
}

func loop_md5(onPath string, toPath string) {
	loop_md5_2(onPath, toPath, false)

}
func loop_md5_2(onPath string, toPath string, IsDouble bool) (err error) {
	var pathDir = string_remove(toPath)
	if !checkFileIsExist(pathDir) {
		if err := os.MkdirAll(pathDir, 0777); err != nil {
			// println("loop_md5_2", err)
			// fmt.Println("目录不可创建")
			ERROR("目录不可创建 loop_md5_2 %s", err)
		}
	}
	if err = CopyFile(onPath, toPath); err != nil {
		println(err)
	}
	if isZip == true {
		fileSuffix := path.Ext(toPath) //获取文件后缀
		if fileSuffix == ".csv" ||
			fileSuffix == ".xml" ||
			fileSuffix == ".ini" ||
			fileSuffix == ".json" ||
			fileSuffix == ".txt" {
			compressorFile(onPath, toPath)
		}
	}
	if IsDouble {
		waitgroup.Done() //任务完成，将任务队列中的任务数量-1，其实.Done就是.Add(-1)
	}
	return nil
}

func change_path(dir, str string) (str1 string) {
	if dir == "" {
		return str
	} else {
		if string([]byte(str)[:1]) != "/" && string([]byte(str)[1:3]) != ":/" {
			return dir + str
		} else {
			return str
		}
	}
}
func change_num(num_str string) string {
	num, err := strconv.Atoi(num_str)
	if err != nil {
		num = 0
	}
	num += 1

	if 0 < num && num < 10 {
		return "0" + strconv.Itoa(num)
	} else {
		return strconv.Itoa(num)
	}
}

func change_uint64_str(len int) string {
	return strconv.FormatUint(uint64(len), 10)
}

// uint32 转成bytes
func uint32_to_bytes(len uint32) []byte {
	bytesBuffer := bytes.NewBuffer([]byte{})
	binary.Write(bytesBuffer, binary.BigEndian, len)
	return bytesBuffer.Bytes()
}

// 读取该文件的MD5
func readMD5(path string) string {
	file, inerr := os.Open(path)
	if inerr != nil {
		return ""
	}
	defer file.Close()
	md5hash := md5.New()
	io.Copy(md5hash, file)
	return fmt.Sprintf("%x", md5hash.Sum(nil))
}

// 读取配置
func readConfig(path string) {
	bytes, _ := ioutil.ReadFile(path)
	err := json.Unmarshal(bytes, &config)
	if err != nil {
		ERROR("readConfig:", err.Error())
		os.Exit(5)
	}
}

// 读取配置
func readPlatformConfig(path string) {
	bytes, _ := ioutil.ReadFile(path)
	err := json.Unmarshal(bytes, &platformConfig)
	if err != nil {
		ERROR("readPlatformConfig:", err.Error())
		os.Exit(5)
	}
}

// 读取文件成二进制
func ReadFileByte(filePth string) ([]byte, error) {
	f, err := os.Open(filePth)
	if err != nil {
		return nil, err
	}
	return ioutil.ReadAll(f)
}

// 复制文件
func CopyFile(source string, dest string) (err error) {
	sourcefile, err := os.Open(source)
	if err != nil {
		return err
	}
	defer sourcefile.Close()
	destfile, err := os.Create(dest)
	defer destfile.Close()
	_, err = io.Copy(destfile, sourcefile)
	if err == nil {
		sourceinfo, err := os.Stat(source)
		if err != nil {
			err = os.Chmod(dest, sourceinfo.Mode())
		}
	}
	return
}

// 复制目录
func CopyDir(source string, dest string, optionStr string) (err error) {
	// get properties of source dir
	if optionStr != "" && strings.Index(source, optionStr) != -1 {
		return err
	} // 过滤 optionStr 内容
	sourceinfo, err := os.Stat(source)
	if err != nil {
		return err
	}
	// create dest dir
	err = os.MkdirAll(dest, sourceinfo.Mode())
	if err != nil {
		return err
	}
	directory, _ := os.Open(source)
	objects, err := directory.Readdir(-1)
	for _, obj := range objects {
		sourcefilepointer := source + "/" + obj.Name()
		destinationfilepointer := dest + "/" + obj.Name()
		if obj.IsDir() {
			// create sub-directories - recursively
			err = CopyDir(sourcefilepointer, destinationfilepointer, optionStr)
			if err != nil {
				fmt.Println(err)
			}
		} else {
			// perform copy
			err = CopyFile(sourcefilepointer, destinationfilepointer)
			if err != nil {
				fmt.Println(err)
			}
		}
	}
	return
}

// 压缩文件 onPath: 要压缩的文件 ，，压缩到目标位置文件的位置
func compressorFile(onPath string, toPath string) {
	bytes, err := ioutil.ReadFile(onPath)
	if err != nil {
		fmt.Println("compressorFile err:", err)
	}
	// var fileSuffix string
	fileSuffix := path.Ext(toPath) //获取文件后缀

	path2 := strings.TrimSuffix(toPath, fileSuffix) // 获取路径和文件名
	// fmt.Printf("compressorFile: %s\n", path2)
	pathFileName := path2 + zibSuffix
	//     fmt.Println("compressorType :", compressorType)
	// if compressorType == "zip" {
	//     onFile := path.Base(onPath) //获取文件名带后缀
	//     compressor_zip(pathFileName, onFile, bytes)
	// }else {
	err = ioutil.WriteFile(pathFileName, compressor_zlib(bytes), 0666)
	if err != nil {
		fmt.Println("compressorFile err:", err)
	}
	// }

}

// zlib 压缩
func compressor_zlib(output []byte) []byte {
	var buf bytes.Buffer
	compressor := zlib.NewWriter(&buf)
	n, err := compressor.Write(output)
	if err != nil {
		fmt.Println("compressor_zlib error n,err:", n, err)
	}
	compressor.Close()
	return buf.Bytes()
}

// 压缩
func compressor_zip(pathFileName string, fileName string, output []byte) {
	// var buf bytes.Buffer
	// buf := new(bytes.Buffer)
	buf, _ := os.Create(pathFileName)
	w := zip.NewWriter(buf)
	f, err := w.Create(fileName)
	if err != nil {
		fmt.Println("compressor_zip Create error :", err)
	}
	_, err = f.Write(output)
	if err != nil {
		fmt.Println("compressor_zip Write error :", err)
	}
	err = w.Close()
	if err != nil {
		fmt.Println("compressor_zip Close error :", err)
	}

	// n, err := compressor.Write(output)
	// if err != nil {
	//     fmt.Println("compressor error n,err:", n, err)
	// }
	// compressor.Close()
	// return buf.Bytes()
}

// zlib 解压缩   ---------------------------------------------------------------
func _uncompressorFileOnTest(path1 string) {
	fileSuffix := path.Ext(path1)                      //获取文件后缀
	pathFileSuffix := path.Ext(path1)                  //获取文件后缀
	path2 := strings.TrimSuffix(path1, pathFileSuffix) // 获取路径和文件名
	uncompressorFileOn(path2+zibSuffix, path1, fileSuffix)
}

// zlib 解压缩   onPath:压缩文件路径.z    toPath:目标文件路径 加后缀
func uncompressorFileOnTest(onPath string, toPath string) {
	toPathFileSuffix := path.Ext(toPath) //获取文件后缀
	uncompressorFileOn(onPath, toPath, toPathFileSuffix)
}

func uncompressorFileOn(onPath string, toPath string, toFileSuffix string) {
	fileSuffix := path.Ext(onPath) //获取文件后缀
	if fileSuffix == zibSuffix {
		uncompressorFile(onPath, toPath, toFileSuffix)
	}
}

//  onPath：为压缩文件 xxx.z
func uncompressorFile(onPath string, toPath string, toFileSuffix string) {
	onFile := path.Base(onPath) //获取文件名带后缀
	toPathDir := string_remove(toPath) + "/"

	bytes, err := ioutil.ReadFile(onPath)
	if err != nil {
		fmt.Println("compressorFile err:", err)
	}
	newFileName := strings.Replace(onFile, zibSuffix, toFileSuffix, -1)
	uncompressor(toPathDir+newFileName, bytes)
}

func uncompressor(path2 string, output []byte) []byte {
	b := bytes.NewReader(output)
	r, err := zlib.NewReader(b)
	if err != nil {
		fmt.Println("uncompressor error n,err:", r, err)
	}

	destfile, err := os.Create(path2)
	defer destfile.Close()
	io.Copy(destfile, r)
	r.Close()
	return nil
}

// 去除后缀
func get_remove_Ext(Path string) string {
	pathFileSuffix := path.Ext(Path)                //获取文件后缀
	return strings.TrimSuffix(Path, pathFileSuffix) // 获取路径和文件名
}

/**
 * 判断文件是否存在  存在返回 true 不存在返回false
 */
func checkFileIsExist(filename string) bool {
	var exist = true
	if _, err := os.Stat(filename); os.IsNotExist(err) {
		exist = false
	}
	return exist
}

// 判断路径 是否是目录
func pathIsDir1(Path string) bool {
	var exist = true
	fi, err := os.Stat(Path)
	if err == nil && !fi.IsDir() {
		exist = false
	}
	return exist
}

// 获得文件夹路径        去除路径文件部分
func string_remove(str string) (file string) {
	return path.Dir(str)
}

func DEBUG(formating string, args ...interface{}) {
	LOG("DEBUG", formating, args...)
}

func INFO(formating string, args ...interface{}) {
	LOG("INFO", formating, args...)
}

func ERROR(formating string, args ...interface{}) {
	LOG("ERROR", formating, args...)
}

func LOG(level string, formating string, args ...interface{}) {
	filename, line := "???", 0
	_, filename, line, ok := runtime.Caller(2)
	// pc, filename, line, ok := runtime.Caller(2)
	// fmt.Println(reflect.TypeOf(pc), reflect.ValueOf(pc))
	if ok {
		// funcname = runtime.FuncForPC(pc).Name()       // main.(*MyStruct).foo
		// funcname = filepath.Ext(funcname)             // .foo
		// funcname = strings.TrimPrefix(funcname, ".")  // foo

		filename = filepath.Base(filename) // /full/path/basename.go => basename.go
	}
	fmt.Printf("%s:%d: %s: %s\n", filename, line, level, fmt.Sprintf(formating, args...))
}

// 写入日志文件
func logFileWrite(content string) {
	logDay := time.Now().Format(FormatDay)
	logName := logPath + "filebranch_" + logDay + ".log"
	logTime := time.Now().Format(FormatTime)
	str := logTime + "\t" + content + "\r\n"
	if checkFileIsExist(logName) {
		versionBytes, _ := ioutil.ReadFile(logName)
		str = string(versionBytes) + str
	}
	ioutil.WriteFile(logName, []byte(str), 0666)
	fmt.Println(content)
}
