util.AddNetworkString("votes.sendVotePrompt")
util.AddNetworkString("votes.receiveVoteResponse")
util.AddNetworkString("votes.sendVote")

util.AddNetworkString("votes.gameVoteMap")
util.AddNetworkString("votes.receiveGameVote")


/*
	Vote library for general votes. 
*/
local nextID = 1
local haveVoted = {}

net.Receive("votes.receiveVoteResponse", function(_, client)
	local voteNumber = net.ReadInt(32)
	local decision   = net.ReadString()

	local vote = ndoc.table.gmVotes[ voteNumber ]
	if (not vote) then return end
	
	local isAVoter = false
	for k,v in ndoc.pairs(vote.players) do
		if (v == client) then isAVoter = true end
	end

	if (not isAVoter) then return end
	if (haveVoted[ voteNumber ][ client ]) then return end

	if (decision == vote.yesText) then
		ndoc.table.gmVotes[ voteNumber ].yes = ndoc.table.gmVotes[ voteNumber ].yes + 1
	else
		ndoc.table.gmVotes[ voteNumber ].no = ndoc.table.gmVotes[ voteNumber ].no + 1
	end

	haveVoted[ voteNumber ][ client ] = true
end)

--returns yes or no( true for yes, false for no), yes votes, no votes, total votes
function gm:getVoteStatus(voteNumber)
	local yes, no = 0, 0

	local vote = ndoc.table.gmVotes[ voteNumber ]
	local yes, no, yesNum, noNum = vote.yesText, vote.noText, vote.yes, vote.no

	return yes > no, {yes, no, yes + no}
end

function gm:createNewVote(title, description, players, callback, yesText, noText, length)
	local thisVoteNumber = nextID

	local voteInfo = {}
	voteInfo.id = thisVoteNumber
	voteInfo.title = title
	voteInfo.desc  = description
	voteInfo.players = players
	voteInfo.yesText = yesText
	voteInfo.noText  = noText
	voteInfo.yes = 0
	voteInfo.no  = 0
	voteInfo.length  = length

	timer.Create("voteTimer.".. thisVoteNumber, length, function()
		local decision, stuff = gm:getVoteStatus(thisVoteNumber)

		ndoc.table.gmVotes[ thisVoteNumber ] = nil
		haveVoted[ thisVoteNumber ] = nil

		callback(decision, voteInfo, stuff)
	end)

	ndoc.table.gmVotes[ thisVoteNumber ] = voteInfo
	haveVoted[ thisVoteNumber ] = nil

	nextID = nextID + 1
end

/* 
	Vote library for game voting.
*/
net.Receive("votes.receiveGameVote", function(l, client)
	local game = net.ReadString()

	if (not gm.games[ game ]) then return end
	if (ndoc.table.gmGameVotes.playersVoted[ client ]) then return end

	ndoc.table.gmGameVotes.playersVoted[ client ] = 1
	ndoc.table.gmGameVotes.games[ game ][ client ] = 1
end)

local function resetNdocTable()
	ndoc.table.gmGameVotes = {games = {}, playersVoted = {}}

	for k,v in pairs(gm.games) do
		ndoc.table.gmGameVotes.games[ k ] = {}
	end
end

function gm:getGameMostVoted()

	local maxVotesForGame = 0
	local maxVotedGame = nil
	for k,v in ndoc.pairs(ndoc.table.gmGameVotes.games) do
		if (#v >= maxVotesForGame) then
			maxVotesForGame = #v
			maxVotedGame = k
		end
	end

	return maxVotedGame, maxVotesForGame
end

function gm:voteForNextGame(length, callback)
	ndoc.table.gmGameVotes = {games = {}, votes = 0}
	local playersWhoCanVote = self:getPlayers()
	local playersCount = #playersWhoCanVote

	resetNdocTable()

	net.Start("votes.gameVoteMap")
	net.Send(playersWhoCanVote)

	hook.Add("Think", "WaitForAllPlayersToVote", function()
		local c = 0
		for k,v in ndoc.pairs(ndoc.table.gmGameVotes.playersVoted) do
			c = c + 1
		end

		if (playersCount == c) then
			hook.Remove("Think", "WaitForAllPlayersToVote")

			local votedGame = gm:getGameMostVoted()

			callback(votedGame)
		end
	end)
end

concommand.Add("createGameVote", function()
	gm:voteForNextGame(function(name) print('VOTED FOR WON: ', name) end)
end)