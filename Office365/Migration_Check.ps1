

Get-MigrationBatch -Identity <batch name> | Format-List Status,Endpoint

Get-MigrationUserStatistics -Identity <MigrationUserIdParameter> -IncludeReport | Format-List Status,Error,Report,SkippedItemCount,SkippedItems
