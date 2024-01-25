
  set outputDir ../output_products
  set outputDirImage $outputDir/image 
  set buildFolder "test"
  file mkdir $outputDirImage/$buildFolder 
  catch {file copy -force $outputDir/TOP_BD_wrapper.ltx $outputDirImage/$buildFolder/TOP_BD_wrapper.ltx} 
  catch {file copy -force $outputDir/TOP_BD_wrapper.bit $outputDirImage/$buildFolder/TOP_BD_wrapper.bit}
  catch {file copy -force $outputDir/TOP_BD_wrapper.xsa $outputDirImage/$buildFolder/TOP_BD_wrapper.xsa} 


