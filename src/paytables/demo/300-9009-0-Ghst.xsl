<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" exclude-result-prefixes="java" extension-element-prefixes="my-ext" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my-ext="ext1">
<xsl:import href="HTML-CCFR.xsl"/>
<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
<xsl:template match="/">
<xsl:apply-templates select="*"/>
<xsl:apply-templates select="/output/root[position()=last()]" mode="last"/>
<br/>
</xsl:template>
<lxslt:component prefix="my-ext" functions="formatJson retrievePrizeTable">
<lxslt:script lang="javascript">
					
					var debugFeed = [];
					var debugFlag = false;
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param
					function formatJson(odeResponseJson, prizeNames, convertedPrizeValues, collections, boardDimensions, translations)
					{
						var scenario = getScenario(odeResponseJson);
						var board = getOutcomeData(scenario, 0);
						var coords = getOutcomeData(scenario, 1);
						var prizeNamesList = prizeNames.split(",");
						var collectionsList = collections.split(",");
						var prizeValues = (convertedPrizeValues.substring(1)).split('|');
						var instantWinPrizes = prizeNamesList.slice();
						var boardWidth = boardDimensions.split(",")[0];
						var boardHeight = boardDimensions.split(",")[1];
						
						registerDebugText("Prize Names: " + prizeNamesList);
						
						// visible board
						var visibleBoard = [];
						for(var x = 0; x &lt; boardWidth; ++x)
						{
							visibleBoard.push("");
							for(var y = 0; y &lt; boardHeight; ++y)
							{
								visibleBoard[x] += board[x][y];
							}
						}
						
						//registerDebugText("Scenario: " + scenario);
						
						// Remove non instant wins
						for(var i = 0; i &lt; instantWinPrizes.length; ++i)
						{
							if(isNaN(instantWinPrizes[i]))
							{
								instantWinPrizes.splice(i, 1);
								--i;
							}
						}
						
						// Checking Cells 2D arrays
						var checkedCells = [[],[],[],[],[],[],[]];
						for(var i = 0; i &lt; 7; ++i)
						{
							for(var j = 0; j &lt; 7; ++j)
							{
								checkedCells[i][j] = false;
							}
						}
						
						var prizeTotals = [];
						for(var i = 0; i &lt; prizeNamesList.length; ++i)
						{
							prizeTotals.push(0);
						}
						
						//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			
						// Print Translation Table to !DEBUG
						var index = 1;
						//registerDebugText("Translation Table");
						while(index &lt; translations.item(0).getChildNodes().getLength())
						{
							var childNode = translations.item(0).getChildNodes().item(index);
							//registerDebugText(childNode.getAttribute("key") + ": " +  childNode.getAttribute("value"));
							index += 2;
						}
						/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						
						// Output winning numbers table.
						var r = [];
						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
						
						var MatchedCells = [];
						var MatchedValues = [];
						var MatchedValuesTranslated = [];
						for(var i = 0; i &lt; coords.length; ++i)
						//for(var i = 0; i &lt; 2; ++i)
						{
							// Present Board
							/*registerDebugText("CURRENT BOARD---------------------------------------------------------------------------------------------------------------------");
							for(var y = visibleBoard.length - 1; y &gt;= 0 ; y--)
							{
								var boardRow = [];
								for(var x = 0; x &lt; visibleBoard[y].length; ++x)
								{
		 							boardRow.push(getTranslationByName(visibleBoard[y][x], translations));
								}
								registerDebugText("Row " + (y+1) + ": " + boardRow);
								boardRow = [];
							}
							registerDebugText("--------------------------------------------------------------------------------------------------------------------------------");*/
							
							var yLoc = coords[i][0] - 1;
							var xLoc = coords[i][1] - 1;
							var checkValue = visibleBoard[xLoc][yLoc];
							registerDebugText("Turn " + (i+1) + ": (" + xLoc + ", " + yLoc + ")");
							registerDebugText("Cube at Location (" + xLoc + ", " + yLoc + "): " + getTranslationByName(checkValue, translations));
						
							if(checkValue == "X")
							{
								getCubesAroundCenter(xLoc, yLoc, MatchedCells);
							}
							else
							{
								getCubeAdjacentLocation(checkValue, xLoc, yLoc, board, boardWidth, boardHeight, checkedCells, MatchedCells);
							}
							registerDebugText("Matched Cell Locations: " + MatchedCells);
							
							var stringRemove = "";
							for(var j = 0; j &lt; MatchedCells.length; ++j)
							{
								var MatchedCellX = Number(MatchedCells[j][0]);
								var MatchedCellY = Number(MatchedCells[j][1]);
								stringRemove = board[MatchedCellX];
								
								stringRemove = board[MatchedCellX].substring(0, MatchedCellY) + "Z";
								stringRemove = stringRemove.concat(board[MatchedCellX].substring(MatchedCellY + 1));
								
								/*registerDebugText("MatchedCell X Index: " + MatchedCellX);
								registerDebugText("MatchedCell Y Index: " + MatchedCellY);
								registerDebugText("String BEFORE Replacement: " + board[MatchedCellX]);
								registerDebugText("String AFTER Replacement: " + stringRemove);
								registerDebugText("Board Length: " + board.length);
								registerDebugText("Board Element[" + MatchedCellX + "] Length: " + board[MatchedCellX].length);
								registerDebugText("Board Element[" + MatchedCellX + "] Expected Length: " + stringRemove.length);*/
								
								board[MatchedCellX] = stringRemove;
								stringRemove = "";
								
								//registerDebugText("Board Element[" + MatchedCellX + "] AFTER Length: " + board[MatchedCellX].length);
								
								MatchedValues.push(visibleBoard[MatchedCellX][MatchedCellY]);
								MatchedValuesTranslated.push(getTranslationByName(visibleBoard[MatchedCellX][MatchedCellY], translations));
								visibleBoard[MatchedCellX][MatchedCellY] = getTranslationByName("youMatched", translations) + ": " + getTranslationByName(visibleBoard[MatchedCellX][MatchedCellY], translations)
							}
							
							for(var index = 0; index &lt; board.length; ++index)
							{
								registerDebugText("Board Row [" + index + "] BEFORE: " + board[index]);
								board[index] = board[index].replace(/Z/g, "");
								registerDebugText("Board Row [" + index + "] AFTER: " + board[index]);
							}	
							
							registerDebugText("Matched Cells: " + MatchedCells);
							registerDebugText("Matched Values: " + MatchedValues);
							registerDebugText("Matched Translations: " + MatchedValuesTranslated);
							
							for(var prize = 0; prize &lt; prizeNamesList.length; ++prize)
							{
								registerDebugText(getTranslationByName(prizeNamesList[prize], translations) + ": " + countMatched(prizeNamesList[prize], MatchedValues));
							}							 
							
							r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
							
							r.push('&lt;tr&gt;&lt;td&gt;');
	 						r.push(getTranslationByName("turn", translations) + " #" + (i+1));
	 						r.push('&lt;/td&gt;&lt;/tr&gt;');
	 						
							// Show Old Board with Matched Symbols
							//registerDebugText("BEFORE:");
							/*for(var y = visibleBoard.length - 1; y &gt;= 0 ; y--)
							{
								r.push('&lt;tr&gt;');
								//registerDebugText("Row " + j + ": " + visibleBoard[y]);
								for(var x = 0; x &lt; visibleBoard[y].length; ++x)
								{
									var boardItem = visibleBoard[y][x];
									r.push('&lt;td class="tablebody"&gt;');
									if(visibleBoard[y][x].length == 1)
									{
										boardItem = getTranslationByName(visibleBoard[y][x], translations);
									}
	 								r.push(boardItem);
		 							r.push('&lt;/td&gt;');
		 							boardItem = "";
								}
								r.push('&lt;/tr&gt;');
							}*/
							
							r.push('&lt;tr&gt;');
							r.push('&lt;td class="tablehead"&gt;');
	 						r.push(getTranslationByName("cubeColor", translations));
	 						r.push('&lt;/td&gt;');
	 						r.push('&lt;td class="tablehead"&gt;');
	 						r.push(getTranslationByName("numberCollected", translations));
	 						r.push('&lt;/td&gt;');
	 						r.push('&lt;td class="tablehead"&gt;');
	 						r.push(getTranslationByName("cumulativeTotal", translations));
	 						r.push('&lt;/td&gt;');
	 						r.push('&lt;td class="tablehead"&gt;');
	 						r.push(getTranslationByName("prize", translations));
	 						r.push('&lt;/td&gt;');
	 						r.push('&lt;/tr&gt;');
	 						
	 						r.push('&lt;tr&gt;');
	 						for(var prize = 0; prize &lt; prizeNamesList.length; ++prize)
							{
								var numCollected = countMatched(prizeNamesList[prize], MatchedValues);
								
								prizeTotals[prize] += numCollected;
							
								r.push('&lt;tr&gt;');
								
								r.push('&lt;td class="tablebody"&gt;');
								if(isNaN(prizeNamesList[prize]))
								{
									r.push(getTranslationByName(prizeNamesList[prize], translations));
								}
								else
								{
									r.push(getTranslationByName(prizeNamesList[prize], translations) + " (" + getTranslationByName("instantWin", translations) + ")");
								}
								r.push('&lt;/td&gt;');
								
								r.push('&lt;td class="tablebody"&gt;');
								if(numCollected &gt; 0)
								{
									r.push(numCollected);
								}
								r.push('&lt;/td&gt;');
								
								r.push('&lt;td class="tablebody"&gt;');
								if(collectionsList[prize] &gt; 1)
								{
									r.push(prizeTotals[prize] + "/" + collectionsList[prize]);
								}
								r.push('&lt;/td&gt;');
								
								r.push('&lt;td class="tablebody"&gt;');
								if(prizeTotals[prize] &gt;= collectionsList[prize] &amp;&amp; numCollected &gt; 0)
								{
									r.push(prizeValues[prize]);
								}
								r.push('&lt;/td&gt;');							
								
								r.push('&lt;/tr&gt;');
							}	
							r.push('&lt;/tr&gt;');
							r.push('&lt;/table&gt;');
							
							// Reset Board
							visibleBoard = [[],[],[],[],[],[],[]];
							for(var x = 0; x &lt; boardWidth; ++x)
							{
								for(var y = 0; y &lt; boardHeight; ++y)
								{
									//registerDebugText("Board Item[" + y + "][" + x + "]: " + board[y][x]);
									if(typeof board[y][x] != 'undefined')
									{
										visibleBoard[x][y] = board[x][y];
									}
									else
									{
										registerDebugText("Board Item[" + y + "][" + x + "] is undefined");
									}
									
								}
							}
							
							MatchedCells = [];
							MatchedValues = [];
							MatchedValuesTranslated = [];
							
							// Reset All Checked Cells
							for(var j = 0; j &lt; 7; ++j)
							{
								for(var k = 0; k &lt; 7; ++k)
								{
									checkedCells[j][k] = false;
								}
							}
						}
						
						r.push('&lt;/table&gt;');
						
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
							for(var idx = 0; idx &lt; debugFeed.length; ++idx)
							{
								if(debugFeed[idx] == "")
									continue;
								r.push('&lt;tr&gt;');
								r.push('&lt;td class="tablebody"&gt;');
								r.push(debugFeed[idx]);
								r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');
							}
							r.push('&lt;/table&gt;');
						}

						return r.join('');
					}
					
					
					/////////////////////////
					// Color Cubes Logic
					
					function getCubeAdjacentLocation(checkValue, xLoc, yLoc, board, width, height, checkedCells, matchedCells)
					{
						var minX = 0;
						var minY = 0;
						var maxX = width - 1;
						var maxY = height - 1;
						//registerDebugText("(" + xLoc + ", " + yLoc + ")");
						if(xLoc &gt; maxX || xLoc &lt; minX || yLoc &gt; maxY || yLoc &lt; minY)
						{
							//registerDebugText("OUT OF BOUNDS");
							return;
						}
						
						if(checkedCells[xLoc][yLoc] == false)
						{
							if(board[xLoc][yLoc] == checkValue)
							{
								//registerDebugText("Value '" + checkValue + "' FOUND....Checking Adjacencies....");
								matchedCells.push(xLoc + "" + yLoc);
								checkedCells[xLoc][yLoc] = true;
							
								// Check Left
								//registerDebugText("(" + xLoc + ", " + yLoc + ")...Checking LEFT....");
								getCubeAdjacentLocation(checkValue, xLoc - 1, yLoc, board, width, height, checkedCells, matchedCells);
								
								//Check Top
								//registerDebugText("(" + xLoc + ", " + yLoc + ")...Checking TOP....");
								getCubeAdjacentLocation(checkValue, xLoc, yLoc + 1, board, width, height, checkedCells, matchedCells);
								
								// Check Right
								//registerDebugText("(" + xLoc + ", " + yLoc + ")...Checking RIGHT....");
								getCubeAdjacentLocation(checkValue, xLoc + 1, yLoc, board, width, height, checkedCells, matchedCells);
								
								// Check Bottom
								//registerDebugText("(" + xLoc + ", " + yLoc + ")...Checking BOTTOM....");
								getCubeAdjacentLocation(checkValue, xLoc, yLoc - 1, board, width, height, checkedCells, matchedCells);
							}
							else
							{
								//registerDebugText("Value '" + checkValue + "' NOT FOUND!!! END CYCLE!!!");
							}
							checkedCells[xLoc][yLoc] = true;
						}
						else
						{
							//registerDebugText("ALREADY CHECKED!!!");
						}
					}
					
					function getCubesAroundCenter(xLoc, yLoc, matchedCells)
					{
						// Center
						matchedCells.push(xLoc + "" + yLoc);
						
						// Top
						matchedCells.push(xLoc + "" + (yLoc+1));
						
						// Bottom
						matchedCells.push(xLoc + "" + (yLoc-1));
						
						// Left
						matchedCells.push((xLoc-1) + "" + yLoc);
						
						// Top Left
						matchedCells.push((xLoc-1) + "" + (yLoc+1));
						
						// Bottom Left
						matchedCells.push((xLoc-1) + "" + (yLoc-1));
						
						// Right
						matchedCells.push((xLoc+1) + "" + yLoc);
						
						// Top Right
						matchedCells.push((xLoc+1) + "" + (yLoc+1));
						
						// Bottom Right
						matchedCells.push((xLoc+1) + "" + (yLoc-1));
					}
					
					function countMatched(matchValue, checkArray)
					{
						var count = 0;
						for(var i = 0; i &lt; checkArray.length; ++i)
						{
							if(matchValue == checkArray[i])
							{
								count++;
							}
						}
						return count;
					}

					/////////////////
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["23", "9", "31"]
					function getWinningNumbers(scenario)
					{
						var numsData = scenario.split("|")[0];
						return numsData.split(",");
					}
					
					// Input: e.g. "FBBEFFAAF,F2BEEEDDBDDAC,FFAXDCECDEDABEEF,EAABC1CAAEDDB,ABFCBABCCBFCCXDC,EBXAAAFFCEBBF,DEDDADF3ECC|24,63,36,63,11,27,45,32,44"
					// Output: e.g ["FBBEFFAAF", "F2BEEEDDBDDAC", "FFAXDCECDEDABEEF", "EAABC1CAAEDDB", ...] or ["24", "63", "36", "11",...]
					function getOutcomeData(scenario, index)
					{
						var outcomeData = scenario.split("|")[index];
						var outcomePairs = outcomeData.split(",");
						var result = [];
						for(var i = 0; i &lt; outcomePairs.length; ++i)
						{
							result.push(outcomePairs[i]);
						}
						return result;
					}
					
					function filterCollectables(scenario)
					{
						var simpleCollections = scenario.split("|")[1];
						
						return simpleCollections;			
					}
					
					function countPrizeCollections(prizeName, scenario)
					{
						//registerDebugText("Checking for prize in scenario: " + prizeName);
						var count = 0;
						for(var char = 0; char &lt; scenario.length; ++char)
						{
							if(prizeName == scenario[char])
							{
								count++;
							}
						}
						
						return count;
					}

					// Input: List of winning numbers and the number to check
					// Output: true is number is contained within winning numbers or false if not
					function checkMatch(winningNums, boardNum)
					{
						for(var i = 0; i &lt; winningNums.length; ++i)
						{
							if(winningNums[i] == boardNum)
							{
								return true;
							}
						}
						
						return false;
					}
					
					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{
						var prizes = prizeNames.split(",");
						
						for(var i = 0; i &lt; prizes.length; ++i)
						{
							if(prizes[i] == currPrize)
							{
								return i;
							}
						}
						
						return -1;
					}
					
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeTables, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeTableStrings = prizeTables.split("|");
						
						
						for(var i = 0; i &lt; pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeTableStrings[i];
							}
						}
						
						return "";
					}
					
					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index &lt; translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.getAttribute("key") == keyName)
							{
								return childNode.getAttribute("value");
							}
							
							index += 2;
						}
					}
					
				</lxslt:script>
</lxslt:component>
<xsl:template match="root" mode="last">
<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWager']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWins']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="SignedData/Data/Outcome/OutcomeDetail/Payout"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:template>
<xsl:template match="//Outcome">
<xsl:if test="OutcomeDetail/Stage = 'Scenario'">
<xsl:call-template name="Scenario.Detail"/>
</xsl:if>
</xsl:template>
<xsl:template name="Scenario.Detail">
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
<tr>
<td class="tablebold" background="">
<xsl:value-of select="//translation/phrase[@key='transactionId']/@value"/>
<xsl:value-of select="': '"/>
<xsl:value-of select="OutcomeDetail/RngTxnId"/>
</td>
</tr>
</table>
<xsl:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())"/>
<xsl:variable name="translations" select="lxslt:nodeset(//translation/)"/>
<xsl:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)"/>
<xsl:variable name="prizeNames">A,B,C,D,E,F,1,2,3</xsl:variable>
<xsl:variable name="pricePoints">100,200,300,500</xsl:variable>
<xsl:variable name="prizeValuesAllPricePoints">750000,25000,4000,1500,400,100,2000,800,200|1000000,15000,6500,2500,800,200,3500,1500,400|2500000,25000,10000,3500,1200,300,5000,2000,600|5000000,100000,20000,7500,2000,500,10000,4000,1000</xsl:variable>
<xsl:variable name="collections">11,10,9,8,7,6,1,1,1</xsl:variable>
<xsl:variable name="boardDimensions">7,7</xsl:variable>
<xsl:variable name="prizeTable">
<xsl:value-of select="my-ext:retrievePrizeTable($pricePoints, $prizeValuesAllPricePoints, $wageredPricePoint)"/>
</xsl:variable>
<xsl:variable name="convertedPrizeValues">
<xsl:call-template name="split">
<xsl:with-param name="pText" select="string($prizeTable)"/>
</xsl:call-template>
</xsl:variable>
<xsl:value-of select="my-ext:formatJson($odeResponseJson, $prizeNames, string($convertedPrizeValues), $collections, $boardDimensions, $translations)" disable-output-escaping="yes"/>
</xsl:template>
<xsl:template name="split">
<xsl:param name="pText"/>
<xsl:if test="string-length($pText)">
<xsl:text>|</xsl:text>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="substring-before(concat($pText,','),',')"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
<xsl:call-template name="split">
<xsl:with-param name="pText" select="substring-after($pText,',')"/>
</xsl:call-template>
</xsl:if>
</xsl:template>
<xsl:template match="text()"/>
</xsl:stylesheet>
