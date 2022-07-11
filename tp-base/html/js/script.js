var type = "normal";
var disabled = false;
var disabledFunction = null;
var canClickButton   = true;

var slots = [null, null, null, null, null, null, null];
var emptyHtml = '<p style="text-align:center;vertical-align: middle; color: gray; text-shadow: 0 0 5px rgb(143, 0, 0); opacity: 0.2; line-height: 120px;"></p>';
var slotsHtml = [emptyHtml, emptyHtml, emptyHtml, emptyHtml, emptyHtml];
var selectedSource = 0;

var currentPlate = "none";
var secondInventoryType = "none";

var secondInventoryHasTargetSource = false;
var secondInventoryTargetSource = 0;

const loadScript = (FILE_URL, async = true, type = "text/javascript") => {
    return new Promise((resolve, reject) => {
        try {
            const scriptEle = document.createElement("script");
            scriptEle.type = type;
            scriptEle.async = async;
            scriptEle.src =FILE_URL;

            scriptEle.addEventListener("load", (ev) => {
                resolve({ status: true });
            });

            scriptEle.addEventListener("error", (ev) => {
                reject({
                    status: false,
                    message: `Failed to load the script ${FILE_URL}`
                });
            });

            document.body.appendChild(scriptEle);
        } catch (error) {
            reject(error);
        }
    });
};

loadScript("js/locales/locales-" + Config.Locale + ".js").then( data  => { 
	console.log("Successfully loaded " + Config.Locale + " locale file.", data); 

	// Loading Sidebar locales manually in order to prevent it from changing from english to the selected language after an amount of milliseconds (bug)
	document.getElementById("sidebar_inventory_option").innerHTML = Locales.sideBarInventory;
	document.getElementById("sidebar_personalprofile_option").innerHTML = Locales.sidebarPersonalProfile;
	document.getElementById("sidebar_scoreboard_option").innerHTML = Locales.sidebarScoreboard;
	document.getElementById("sidebar_tickets_option").innerHTML = Locales.sidebarTickets;

}) .catch( err => { console.error(err); });


function closeInventory() {
    $.post("http://tp-base/closeNUI", JSON.stringify({}));
	$('#playerInventory').html('');
	$('#selectedPlayerInventory').html('');

	$('#secondPlayerInventory').html('');
	$('#secondInventory').html('');

	$("#playerAchievements").html("");
    $("#otherPlayerAchievements").html("");

	$('#userslist').html('');
	$('#ticket').html('');

	currentPlate = "none";

	secondInventoryType = "none";
	secondInventoryHasTargetSource = false;
	secondInventoryTargetSource = 0;
}

function playAudio(sound) {
	var audio = new Audio('./sounds/' + sound);
	audio.volume = Config.DefaultClickSoundVolume;
	audio.play();
}

function setClickableOptionsShadow(id) {
	document.getElementById("sidebar_inventory_option").style.textShadow = 'none';
	document.getElementById("sidebar_personalprofile_option").style.textShadow = 'none';
	document.getElementById("sidebar_scoreboard_option").style.textShadow = 'none';
	document.getElementById("sidebar_tickets_option").style.textShadow = 'none';

	document.getElementById("downbar_suggest_option").style.textShadow = 'none';
	document.getElementById("downbar_info_option").style.textShadow = 'none';

	document.getElementById(id).style.textShadow = '0 0 5px white';
}

$(function() {
	
	window.addEventListener('message', function(event) {

		
		if (event.data.type == "enableui") {
			document.body.style.display = event.data.enable ? "block" : "none";
			
			document.getElementById("enable_second_inventory").style.display="none";
			document.getElementById("enable_personal_iformation").style.display="none";
			document.getElementById("enable_selected_user_personal_iformation").style.display="none";
			document.getElementById("ticketui").style.display="none";
			document.getElementById("showtickets").style.display="none";
			document.getElementById("online_users").style.display="none";
			document.getElementById("suggestions_section").style.display="none";
			document.getElementById("info_section").style.display="none";
			document.getElementById("showloading").style.display="none";

			document.getElementById("management").style.display="block";

			// Insert Sidebar Locales
			document.getElementById("sidebar_inventory_option").innerHTML = Locales.sideBarInventory;
			document.getElementById("sidebar_personalprofile_option").innerHTML = Locales.sidebarPersonalProfile;
			document.getElementById("sidebar_scoreboard_option").innerHTML = Locales.sidebarScoreboard;
			document.getElementById("sidebar_tickets_option").innerHTML = Locales.sidebarTickets;

		}else if (event.data.type == "enable_personal_inventory") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("enable_second_inventory").style.display="none";
			document.getElementById("enable_personal_iformation").style.display="none";
			document.getElementById("enable_selected_user_personal_iformation").style.display="none";
			document.getElementById("ticketui").style.display="none";
			document.getElementById("showtickets").style.display="none";
			document.getElementById("online_users").style.display="none";
			document.getElementById("suggestions_section").style.display="none";
			document.getElementById("info_section").style.display="none";
			document.getElementById("showloading").style.display="none";

			document.getElementById("management").style.display="block";
			
			document.getElementById("enable_personal_inventory").style.display="block";

			$(".shortcut-slot1").html(slotsHtml[0]);
			$(".shortcut-slot2").html(slotsHtml[1]);
			$(".shortcut-slot3").html(slotsHtml[2]);
			$(".shortcut-slot4").html(slotsHtml[3]);
			$(".shortcut-slot5").html(slotsHtml[4]);

			$("#give").show();
			$("#drop").show();

			disabled = false;
			canClickButton = true;

			// Insert Inventory Locales
			
			document.getElementById("give").innerHTML = Locales.inventoryGiveItem;
			document.getElementById("drop").innerHTML = Locales.inventoryDropItem;

			setClickableOptionsShadow("sidebar_inventory_option");

		}else if (event.data.type == "enable_second_inventory") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("enable_personal_inventory").style.display="none";
			document.getElementById("enable_personal_iformation").style.display="none";
			document.getElementById("enable_selected_user_personal_iformation").style.display="none";
			document.getElementById("ticketui").style.display="none";
			document.getElementById("showtickets").style.display="none";
			document.getElementById("online_users").style.display="none";
			document.getElementById("suggestions_section").style.display="none";
			document.getElementById("info_section").style.display="none";
			document.getElementById("showloading").style.display="none";

			document.getElementById("management").style.display="none";
			document.getElementById("enable_second_inventory").style.display="block";
			disabled = false;
			canClickButton = true;

		}else if (event.data.type == "enable_personal_iformation") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("enable_second_inventory").style.display="none";
			document.getElementById("enable_personal_inventory").style.display="none";
			document.getElementById("enable_selected_user_personal_iformation").style.display="none";
			document.getElementById("ticketui").style.display="none";
			document.getElementById("showtickets").style.display="none";
			document.getElementById("online_users").style.display="none";
			document.getElementById("suggestions_section").style.display="none";
			document.getElementById("info_section").style.display="none";
			document.getElementById("showloading").style.display="none";

			document.getElementById("management").style.display="block";
			document.getElementById("enable_personal_iformation").style.display="block";

			canClickButton = true;

		}else if (event.data.type == "enable_selected_user_personal_iformation") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("enable_second_inventory").style.display="none";
			document.getElementById("enable_personal_inventory").style.display="none";
			document.getElementById("enable_personal_iformation").style.display="none";
			document.getElementById("ticketui").style.display="none";
			document.getElementById("showtickets").style.display="none";
			document.getElementById("online_users").style.display="none";
			document.getElementById("suggestions_section").style.display="none";
			document.getElementById("info_section").style.display="none";
			document.getElementById("showloading").style.display="none";

			document.getElementById("management").style.display="block";
			document.getElementById("enable_selected_user_personal_iformation").style.display="block";

			canClickButton = true;

		}else if (event.data.action == "changePlayerAvatar"){
			document.getElementById("avatar_image").src = event.data.avatar_url;
			document.getElementById("avatar_url_input").value = event.data.avatar_url;
		}else if (event.data.action == "addPlayerInformation") {

			document.getElementById("avatar_image").src = event.data.avatar_url;
			document.getElementById("avatar_url_input").value = event.data.avatar_url;

			document.getElementById("header_character_stats_money").innerHTML = "💲" + event.data.money;
			document.getElementById("header_character_stats_bank").innerHTML = " 🏦 " + event.data.bank;
			document.getElementById("header_character_stats_blackmoney").innerHTML = " 💰 " + event.data.black_money;

			// Inserting Profile Locales.
			document.getElementById("avatar_url_set").innerHTML = Locales.profileChangeUrl;

			document.getElementById("header_avatar").innerHTML = Locales.profileTitle + " - " + event.data.steamName + " (" + event.data.name + ")";

			document.getElementById("header_character_stats").innerHTML = Locales.profileCharacterStatistics;
			document.getElementById("header_character_stats_description").innerHTML = Locales.profileStatisticsOverview;

			document.getElementById("header_character_stats_money_title").innerHTML = Locales.profileHoldingCash;
			document.getElementById("header_character_stats_bank_title").innerHTML = Locales.profileBankAccount;
			document.getElementById("header_character_stats_black_money_title").innerHTML = Locales.profileBlackMoney;

		}else if (event.data.action == "addSelectedPlayerInformation") {

			document.getElementById("selected_avatar_image").src = event.data.avatar_url;

			document.getElementById("other_header_character_stats_money").innerHTML = "💲" + event.data.money;
			document.getElementById("other_header_character_stats_bank").innerHTML = " 🏦 " + event.data.bank;
			document.getElementById("other_header_character_stats_blackmoney").innerHTML = " 💰 " + event.data.black_money;

			selectedSource = event.data.source;

			// Inserting Profile Locales.

			document.getElementById("other_header_avatar").innerHTML = Locales.profileTitle + " - " + event.data.steamName + " (" + event.data.name + ")";

			document.getElementById("other_header_character_stats").innerHTML = Locales.profileCharacterStatistics;
			document.getElementById("other_header_character_stats_description").innerHTML = Locales.profileStatisticsOverview;

			document.getElementById("other_header_character_stats_money_title").innerHTML = Locales.profileHoldingCash;
			document.getElementById("other_header_character_stats_bank_title").innerHTML = Locales.profileBankAccount;
			document.getElementById("other_header_character_stats_black_money_title").innerHTML = Locales.profileBlackMoney;

			document.getElementById("other_header_character_refresh").innerHTML = Locales.profileRefresh;

		}else if (event.data.action == "addSelectedPlayerInformationOnRefresh") {

			document.getElementById("other_header_character_stats_money").innerHTML = "💲" + event.data.money;
			document.getElementById("other_header_character_stats_bank").innerHTML = " 🏦 " + event.data.bank;
			document.getElementById("other_header_character_stats_blackmoney").innerHTML = " 💰 " + event.data.black_money;


		}else if (event.data.type == "enable_online_users") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("enable_second_inventory").style.display="none";
			document.getElementById("enable_personal_inventory").style.display="none";
			document.getElementById("enable_personal_iformation").style.display="none";
			document.getElementById("enable_selected_user_personal_iformation").style.display="none";
			document.getElementById("ticketui").style.display="none";
			document.getElementById("showtickets").style.display="none";
			document.getElementById("suggestions_section").style.display="none";
			document.getElementById("info_section").style.display="none";
			document.getElementById("showloading").style.display="none";

			document.getElementById("management").style.display="block";
			document.getElementById("online_users").style.display="block";

			canClickButton = true;

			// Insert Online Player Locales
			document.getElementById("userslist_header_description").innerHTML = Locales.scoreboardOnlinePlayers;
			document.getElementById("userslist_steamname_header").innerHTML = Locales.scoreboardSteamName;
			document.getElementById("userslist_username_header").innerHTML = Locales.scoreboardUserName;
			document.getElementById("userslist_id_header").innerHTML = Locales.scoreboardId;
			document.getElementById("userslist_ms_header").innerHTML = Locales.scoreboardMS;

		}else if (event.data.type == "enable_ticket") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("enable_second_inventory").style.display="none";
			document.getElementById("enable_personal_inventory").style.display="none";
			document.getElementById("enable_personal_iformation").style.display="none";
			document.getElementById("enable_selected_user_personal_iformation").style.display="none";
			document.getElementById("showtickets").style.display="none";
			document.getElementById("online_users").style.display="none";
			document.getElementById("suggestions_section").style.display="none";
			document.getElementById("info_section").style.display="none";
			document.getElementById("showloading").style.display="none";

			document.getElementById("management").style.display="block";
			document.getElementById("ticketui").style.display="block";

			$('#ticket').html('');

			canClickButton = true;

			// Insert Ticket Locales
			document.getElementById("header").innerHTML = Locales.ticketsTitle;
			document.getElementById('ticket_reason_description').placeholder = Locales.ticketsDescription;

			document.getElementById("ticket_create").innerHTML = Locales.ticketsSubmit;
			document.getElementById("ticket_category_manage").innerHTML = Locales.ticketsShowTickets;

		}else if (event.data.type == "enable_tickets_list") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("enable_second_inventory").style.display="none";
			document.getElementById("enable_personal_inventory").style.display="none";
			document.getElementById("enable_personal_iformation").style.display="none";
			document.getElementById("enable_selected_user_personal_iformation").style.display="none";
			document.getElementById("ticketui").style.display="none";
			document.getElementById("online_users").style.display="none";
			document.getElementById("suggestions_section").style.display="none";
			document.getElementById("info_section").style.display="none";
			document.getElementById("showloading").style.display="none";

			document.getElementById("management").style.display="block";
			document.getElementById("showtickets").style.display="block";

			canClickButton = true;

			// Insert Tickets List Locales
			document.getElementById("ticket_category_refresh").innerHTML = Locales.ticketsRefreshTickets;

		}else if (event.data.type == "enable_suggestions_section") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("enable_second_inventory").style.display="none";
			document.getElementById("enable_personal_inventory").style.display="none";
			document.getElementById("enable_personal_iformation").style.display="none";
			document.getElementById("enable_selected_user_personal_iformation").style.display="none";
			document.getElementById("ticketui").style.display="none";
			document.getElementById("showtickets").style.display="none";
			document.getElementById("showloading").style.display="none";
			document.getElementById("info_section").style.display="none";
			document.getElementById("online_users").style.display="none";

			document.getElementById("management").style.display="block";
			document.getElementById("suggestions_section").style.display="block";

			canClickButton = true;

			// Insert Feedback Locales
			document.getElementById("suggestions_description_header").innerHTML = Locales.feedbackTitle;
			document.getElementById('suggestions_description_about').placeholder = Locales.feedbackFirstSubject;
			document.getElementById('suggestions_description').placeholder = Locales.feedbackSecondSubject;
			document.getElementById("suggestions_create").innerHTML = Locales.feedbackSendButton;

		}else if (event.data.type == "enable_info_section") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("enable_second_inventory").style.display="none";
			document.getElementById("enable_personal_inventory").style.display="none";
			document.getElementById("enable_personal_iformation").style.display="none";
			document.getElementById("enable_selected_user_personal_iformation").style.display="none";
			document.getElementById("ticketui").style.display="none";
			document.getElementById("showtickets").style.display="none";
			document.getElementById("showloading").style.display="none";
			document.getElementById("suggestions_section").style.display="none";
			document.getElementById("online_users").style.display="none";

			document.getElementById("management").style.display="block";
			document.getElementById("info_section").style.display="block";

			canClickButton = true;

			// Insert Info Locales
			document.getElementById("info_commands_option").innerHTML = Locales.informationCommandsOption;

			document.getElementById("info_keybinds_option").style.textShadow = 'none';
			document.getElementById("info_commands_option").style.textShadow = '0 0 5px white';

			document.getElementById("info_keybinds_option").innerHTML = Locales.informationKeybindsOption;
			document.getElementById("info_commands_and_keybinds").innerHTML = Locales.informationCommands;

		}else if (event.data.type == "enable_loading") {
			document.body.style.display = event.data.enable ? "block" : "none";

			document.getElementById("enable_second_inventory").style.display="none";
			document.getElementById("enable_personal_inventory").style.display="none";
			document.getElementById("enable_personal_iformation").style.display="none";
			document.getElementById("enable_selected_user_personal_iformation").style.display="none";
			document.getElementById("ticketui").style.display="none";
			document.getElementById("showtickets").style.display="none";
			document.getElementById("suggestions_section").style.display="none";
			document.getElementById("info_section").style.display="none";
			document.getElementById("online_users").style.display="none";

			document.getElementById("management").style.display="block";
			document.getElementById("showloading").style.display="block";

			canClickButton = false;


		}else if (event.data.action == "addOnlinePlayersInGame") {
			document.getElementById("userslist_header_description").innerHTML = Locales.scoreboardOnlinePlayers + event.data.onlinePlayers;


		}else if (event.data.action == "updatePlayerJobs") {
			var jobs = event.data.jobs;

			document.getElementById("userslist_header_jobs").innerHTML = 
			"👮Police: " + jobs.police + 
			" ‍ ‍ ‍🚑Ambulance: " + jobs.ambulance + 
			" ‍ ‍ ‍🚕Taxi: " + jobs.taxi + 
			" ‍ ‍ ‍🔧Bennys: " + jobs.bennys + 
			" ‍ ‍ ‍🔧LS Customs: " + jobs.lscustom;

		}else if (event.data.action == "addOnlinePlayer") {
			var prod_player = event.data.player_det;

			$("#userslist").append(
				`<div id="userslist_main">`+
				`<div>`+

				`</div>`+
				`<span 
				source = ` + prod_player.id + 
				` identifier = ` + prod_player.identifier + 
				` steamName = ` + prod_player.steamName + 
				` name = ` + prod_player.name + 
				` money = ` + prod_player.money + 
				` bank = ` + prod_player.bank + 
				` black_money = ` + prod_player.black_money + 
				` id ="userlist_name_display">` + prod_player.steamName 
				
				+ ` </span>`+

				`<span class = "userlist_displays" id="userlist_username_display">` + prod_player.name + ` </span>`+
				`<span class = "userlist_displays" id="userlist_id_display">` + prod_player.id + ` </span>`+
				`<span class = "userlist_displays" id="userlist_ping_display"> ` + prod_player.ping + `</span>`+
				   
				`</div>`+

				`</div>`+
			`</div>`
			);

			canClickButton = true;

			
		}else if (event.data.action == "addPlayerOnLeaderboard") {
			var prod_player = event.data.player_det;

			$("#usersranking").append(
				`<div id="usersranking_main">`+
				`<div id="usersranking_det">`+
				`<div>`+

				`</div>`+
				`<span id="usersranking_id_display">` + prod_player.steamName + ` </span>`+
				`<span id="usersranking_id_display">` + prod_player.name + ` </span>`+
				
				`<span id="usersranking_id_display">` + prod_player.id + ` </span>`+

				`<span id="usersranking_id_display"> ` + prod_player.ping + ` MS </span>`+

				   `<div class = "usersranking_avatar_parent">`+
				       `<div>`+
			      	         `<img identifier = ` + prod_player.identifier + ` id="usersranking_avatar" class="usersranking_avatar" src = "` + prod_player.avatarUrl  +`" />`+
			            `</div>`+
				   `</div>` +
				   
				`</div>`+

				`</div>`+
			`</div>`
			);

			canClickButton = true;

		}else if (event.data.action == "addOnlinePlayersInGame") {
			document.getElementById("userslist_header_description").innerHTML = "Online Players: " + event.data.onlinePlayers;

		}else if (event.data.action == "clearOnlinePlayers") {
			$('#userslist').html('');

		}else if (event.data.action == "clearTickets") {
			$('#ticket').html('');

		}else if (event.data.action == "addPlayerAchievements"){

			if (event.data.otherSource == true){
				playerAchievementsSetup(event.data.achievementsList, true);
			}else{
				playerAchievementsSetup(event.data.achievementsList, false);
			}

		}else if (event.data.action == "addReport") {
			var prod_report = event.data.reports_det;

			if (prod_report.description == "N/A") {
				prod_report.description = Locales.ticketsNoDescription;
			}

			$("#ticket").append(
				`<div id="ticket_main">`+
				`<div id="ticket_det">`+
				`<div>`+
				`<span id="ticket_player_report_dnt">` + prod_report.currentDateTime + ` </span>`+
				`</div>`+
    
				    `<div>`+
			        	`<span> [ PLAYER: ` + prod_report.name  + ` ] ‍ ‍ ‍[ ID: ` + prod_report.source + ` ] </span>`+
			       `</div>`+
				   
				   `<div>`+
				        `<span id="ticket_player_report_id_title">  ‍  ‍  </span>`+
				   `</div>`+

					`<div>`+
				        `<span id="ticket_player_report_reason">[` +  prod_report.reason + `] </span>`+
					`</div>`+

					`<div>`+
					    `<span id="ticket_player_report_description">` + prod_report.description + ` </span>`+
					`</div>`+

					`<div>`+
					    `<span id="ticket_player_report_id_title">  ‍  ‍  </span>`+
					`</div>`+

					`<div id="ticket_teleport" source=`+prod_report.source+`>`+
						Locales.ticketsTeleport+
					`</div>`+


				   `<div id="ticket_state" reportId =`+event.data.reports_id + `>`+
				        Locales.ticketsSetSolved+
			       `</div>`+

				`</div>`+

				`</div>`+
			`</div>`
			);

			canClickButton = true;

		} else if (event.data.action == "shortcut") {
			if (slots[event.data.slot] != null) {
				$.post("http://tp-base/UseItem", JSON.stringify({
					item: slots[event.data.slot]
				}));
	
				if (!slots[event.data.slot].name.includes("WEAPON") && !slots[event.data.slot].name.includes("N_REMOVABLE")){
	
					slots[event.data.slot].count = slots[event.data.slot].count - 1;
	
					// !== undefined
					if (slots[event.data.slot].count == 0) {
						slots[event.data.slot] = null;
						slotsHtml[event.data.slot] = emptyHtml;
						
						var realslot = event.data.slot + 1;
						$(".shortcut-slot" + realslot).html(emptyHtml);
					}
				}
			}
			
		}else if (event.data.action == "clearSlots") {
        
			for(var i = 0; i < 5; i++){
	
				if (slots[i] != null ) {
	
					slots[i] = null;
					slotsHtml[i] = emptyHtml;
	
					$(".shortcut-slot" + i).html(emptyHtml);
				}
			}
			
		}else if (event.data.action == "nodrag") {
			$('.item').draggable("disable");
			$('.secondItem').draggable("disable");
			$('.secondPlayerItem').draggable("disable");
			
		}else if (event.data.action == "setSecondInventoryInformation") {
			secondInventoryType = event.data.inventoryType;

			if (secondInventoryType == "trunk"){

				currentPlate = event.data.plate;
				document.getElementById("secondInventoryHeader").innerHTML = event.data.plate + " | " + Locales.trunkCurrentWeight + event.data.weight + " / " + event.data.maxWeight + " (" + Math.floor((event.data.weight/event.data.maxWeight * 100)) + "%)";
			
			}else{

				secondInventoryHasTargetSource = event.data.hasTargetSource;
				secondInventoryTargetSource = event.data.targetSource;

				document.getElementById("secondInventoryHeader").innerHTML = event.data.header;
			}

		} else if (event.data.action == "setSecondPlayerInventoryItems"){
			secondPlayerInventorySetup(event.data.itemList, "#secondPlayerInventory");

			$('.secondPlayerItem').draggable({
				helper: 'clone',
				appendTo: 'body',
				zIndex: 99999,
				revert: 'invalid',
				start: function (event, ui) {
					if (disabled) {
						return false;
					}
	
					$(this).css('background-image', 'none');
					itemData = $(this).data("secondPlayerItem");
					itemInventory = $(this).data("inventory");
	
				},
				stop: function () {
					itemData = $(this).data("secondPlayerItem");
	
					if (itemData !== undefined && itemData.name !== undefined) {
						$(this).css('background-image', 'url(\'img/items/' + itemData.name + '.png\'');
					}
				}
			});

		} else if (event.data.action == "setSecondInventoryItems"){
			secondInventorySetup(event.data.itemList);

			$('.secondItem').draggable({
				helper: 'clone',
				appendTo: 'body',
				zIndex: 99999,
				revert: 'invalid',
				start: function (event, ui) {
					if (disabled) {
						return false;
					}
	
					$(this).css('background-image', 'none');
					itemData = $(this).data("secondItem");
					itemInventory = $(this).data("inventory");
	
				},
				stop: function () {
					itemData = $(this).data("secondItem");
	
					if (itemData !== undefined && itemData.name !== undefined) {
						$(this).css('background-image', 'url(\'img/items/' + itemData.name + '.png\'');
					}
				}
			});

		} else if (event.data.action == "setItems") {

			if (event.data.isTarget == true) {

				secondPlayerInventorySetup(event.data.itemList, "#selectedPlayerInventory");

			}else{

				inventorySetup(event.data.itemList);

				$(".item").mousedown(function(event) {
					if (disabled || event.which != 3) {
						return false;
					}
					
					itemData = $(this).data("item");
				

					if (itemData !== undefined && itemData.name !== undefined && itemData.usable)
					{
						disableInventory(1500);
						$.post("http://tp-base/UseItem", JSON.stringify({
							item: itemData
						}));
						
						itemData = itemData - 1;
					}
				});
				
				
				$('.shortcut-slot1').click(function(){
					slots[0] = null;
					slotsHtml[0] = emptyHtml;
					
					$(".shortcut-slot1").html(emptyHtml);
		
					$.post("http://tp-base/removeHoldingWeaponOnShortcutClear");
				});
				
				$('.shortcut-slot2').click(function(){
					slots[1] = null;
					slotsHtml[1] = emptyHtml;
					
					$(".shortcut-slot2").html(emptyHtml);
					
					$.post("http://tp-base/removeHoldingWeaponOnShortcutClear");
				});
				
				$('.shortcut-slot3').click(function(){
					slots[2] = null;
					slotsHtml[2] = emptyHtml;
					
					$(".shortcut-slot3").html(emptyHtml);
					
					$.post("http://tp-base/removeHoldingWeaponOnShortcutClear");
				});
				
				$('.shortcut-slot4').click(function(){
					slots[3] = null;
					slotsHtml[3] = emptyHtml;
					
					$(".shortcut-slot4").html(emptyHtml);
					
					$.post("http://tp-base/removeHoldingWeaponOnShortcutClear");
				});
				
				$('.shortcut-slot5').click(function(){
					slots[4] = null;
					slotsHtml[4] = emptyHtml;
					
					$(".shortcut-slot5").html(emptyHtml);
					
					$.post("http://tp-base/removeHoldingWeaponOnShortcutClear");
				});
				
	
				$('.item').draggable({
					helper: 'clone',
					appendTo: 'body',
					zIndex: 99999,
					revert: 'invalid',
					start: function (event, ui) {
						if (disabled) {
							return false;
						}
		
						$(this).css('background-image', 'none');
						itemData = $(this).data("item");
						itemInventory = $(this).data("inventory");
		
					},
					stop: function () {
						itemData = $(this).data("item");
		
						if (itemData !== undefined && itemData.name !== undefined) {
							$(this).css('background-image', 'url(\'img/items/' + itemData.name + '.png\'');
							$("#drop").removeClass("disabled");
							$("#use").removeClass("disabled");
							$("#give").removeClass("disabled");
						}
					}
				});
			}

			
		} else if (event.data.action == "nearPlayers") {
			$("#nearPlayers").html("");
	
			$.each(event.data.players, function (index, player) {
				$("#nearPlayers").append('<button class="nearbyPlayerButton" data-player="' + player.player + '"> ' +  player.label +  ' (' + player.player + ') </button>');
			});
	
			$("#other_dialog").dialog("open");
	
			$(".nearbyPlayerButton").click(function () {
				$("#other_dialog").dialog("close");
				player = $(this).data("player");
				$.post("http://tp-base/GiveItem", JSON.stringify({
					player: player,
					item: event.data.item,
					number: parseInt($("#count").val())
				}));
				$.post("http://tp-base/nodrag");
			});
		}

	});

	/* Displaying player inventory ~button*/
	$("#management").on("click", "#sidebar_inventory_option", function() {

		playAudio("button_click.wav");
		setClickableOptionsShadow("sidebar_inventory_option");

		if (canClickButton) {
			$.post('http://tp-base/openPersonalInventory', JSON.stringify({}))
		}

	});


	/* Displaying player information ~button*/
	$("#management").on("click", "#sidebar_personalprofile_option", function() {

		playAudio("button_click.wav");
		setClickableOptionsShadow("sidebar_personalprofile_option");

		if (canClickButton) {
			$.post('http://tp-base/personalInformation', JSON.stringify({}))
		}

	});

	/* Cancelling enter on input where avatar url is required */
	$("#enable_personal_iformation").on('keyup keypress', 'input', function(e) {
		if(e.which == 13) {
		  e.preventDefault();
		  return false;
		}
	});

	/* Creates a ticket with the selected category reason and description ~button*/
	$("#enable_personal_iformation").on("click", "#avatar_url_set", function() {

		playAudio("button_click.wav");

		$.post('http://tp-base/changeAvatarUrl', JSON.stringify({
			url: $("#avatar_url_input").val(),
		}));
	});
	
	/* Refresh player data ~button*/
	$("#enable_selected_user_personal_iformation").on("click", "#other_header_character_refresh", function() {
		
		playAudio("button_click.wav");

		$.post("http://tp-base/refreshSelectedCharacterData", JSON.stringify({
			source: selectedSource,
		}));
	});
	
	/* Displaying all online players list ~button*/
	$("#management").on("click", "#sidebar_scoreboard_option", function() {

		playAudio("button_click.wav");
		
		setClickableOptionsShadow("sidebar_scoreboard_option");

		if (canClickButton) {
			$.post('http://tp-base/openOnlinePlayersList', JSON.stringify({}))
		}
	});

	/* Creates a ticket with the selected category reason and description ~button*/
	$("#online_users").on("click", "#userlist_name_display", function() {

		playAudio("button_click.wav");

        var $button = $(this);

		if (canClickButton) {
			$.post('http://tp-base/openSelectedPlayerProfile', JSON.stringify({
				identifier: $button.attr('identifier'),
				source: $button.attr('source'),
				steamName: $button.attr('steamName'),
				name: $button.attr('name'),
				money: $button.attr('money'),
				bank: $button.attr('bank'),
				black_money: $button.attr('black_money'),
			}));
		}
	});

	/* Displaying creating ticket section ~button*/
	$("#management").on("click", "#sidebar_tickets_option", function() {

		playAudio("button_click.wav");
		setClickableOptionsShadow("sidebar_tickets_option");

		if (canClickButton) {
			$.post('http://tp-base/openTicketCreation', JSON.stringify({}))
		}
	});


	/* Creates a ticket with the selected category reason and description ~button*/
	$("#ticketui").on("click", "#ticket_create", function() {
		
		playAudio("button_click.wav");

		var descriptionLength = $("#ticket_reason_description").val().length;

		$.post('http://tp-base/submitReport', JSON.stringify({
			description: $("#ticket_reason_description").val(),
			reason: $("#report_reason").val(),
			descriptionLength: descriptionLength,
		}));
	});

	/* Displaying all the available tickets (not solved) ~button*/
	$("#ticketui").on("click", "#ticket_category_manage", function() {

		playAudio("button_click.wav");

		if (canClickButton) {
			$.post('http://tp-base/openTicketsManagement', JSON.stringify({}))
		}
	});

	/* Teleports to the selected player source ~button*/
	$("#ticket").on("click", "#ticket_teleport", function() {
		
		playAudio("button_click.wav");

        var $button = $(this);
        var $source = $button.attr('source')


		$.post('http://tp-base/teleportTo', JSON.stringify({
			source : $source,
		}))

	});

	/* Sets a report as solved ~button*/
	$("#ticket").on("click", "#ticket_state", function() {
		
		playAudio("button_click.wav");

        var $button = $(this);
        var $reportId = $button.attr('reportId')
		$.post('http://tp-base/changeStatus', JSON.stringify({
			reportId : $reportId
		}))

	});


	/* Refresh available tickets (not solved) ~button*/
	$("#showtickets").on("click", "#ticket_category_refresh", function() {
		
		playAudio("button_click.wav");

		$.post("http://tp-base/openTicketsManagement", JSON.stringify({}));

	});

	/* Displaying suggestions section ~button*/
	$("#management").on("click", "#downbar_suggest_option", function() {

		playAudio("button_click.wav");
		setClickableOptionsShadow("downbar_suggest_option");

		if (canClickButton) {
			$.post('http://tp-base/openSuggestionSection', JSON.stringify({}))
		}

	});

	/* Creates a new suggestion ~button*/
	$("#suggestions_section").on("click", "#suggestions_create", function() {
		
		playAudio("button_click.wav");

		$.post('http://tp-base/submitNewSuggestion', JSON.stringify({
			description_about: $("#suggestions_description_about").val(),
			description: $("#suggestions_description").val()

		}));
	});

	/* Displaying info section ~button*/
	$("#management").on("click", "#downbar_info_option", function() {

		playAudio("button_click.wav");
		setClickableOptionsShadow("downbar_info_option");

		if (canClickButton) {
			$.post('http://tp-base/openInformationSection', JSON.stringify({}))
		}
	
	});
	
	// Open Discord Url
	$("#management").on("click", "#downbar_discord_option", function() {

		playAudio("button_click.wav");

		window.invokeNative('openUrl', Config.DiscordUrl); 
		
	});
		
	// Information Commands Section
	$("#info_section").on("click", "#info_commands_option", function() {

		playAudio("button_click.wav");

		document.getElementById("info_keybinds_option").style.textShadow = 'none';
		document.getElementById("info_commands_option").style.textShadow = '0 0 5px white';

		document.getElementById("info_commands_and_keybinds").innerHTML = Locales.informationCommands;
		
	});

	// Information Keybinds Section
	$("#info_section").on("click", "#info_keybinds_option", function() {

		playAudio("button_click.wav");

		document.getElementById("info_commands_option").style.textShadow = 'none';
		document.getElementById("info_keybinds_option").style.textShadow = '0 0 5px white';

		document.getElementById("info_commands_and_keybinds").innerHTML = Locales.informationKeybinds;
		
	});

});

function Interval(time) {
    var timer = false;
    this.start = function () {
        if (this.isRunning()) {
            clearInterval(timer);
            timer = false;
        }

        timer = setInterval(function () {
            disabled = false;
        }, time);
    };
    this.stop = function () {
        clearInterval(timer);
        timer = false;
    };
    this.isRunning = function () {
        return timer !== false;
    };
}


function disableInventory(ms) {
    disabled = true;

    if (disabledFunction === null) {
        disabledFunction = new Interval(ms);
        disabledFunction.start();
    } else {
        if (disabledFunction.isRunning()) {
            disabledFunction.stop();
        }

        disabledFunction.start();
    }
}

function setCount(item, secondInventory) {
    count = item.count

	if (secondInventory) {
        if (item.limit > 0) {
            count = item.count
        }
    }else{
        if (item.limit > 0) {
            count = item.count + " / " + item.limit
        }
    }

	if (!secondInventory && item.type === "item_weapon") {
        if (count == 0) {
            count = "";
        } else {
            count = '<img src="img/items/bullet.png" class="ammoIcon"> ' + item.count;
        }
    }

    if (item.type === "item_account" || item.type === "item_money") {
        count = "💲" + formatMoney(item.count);
    }


    return count;
}

function playerAchievementsSetup(achievements, otherSource){

    $("#playerAchievements").html("");
    $("#otherPlayerAchievements").html("");

	var achievementsCount = 0;

    $.each(achievements, function (index, achievement) {

		//-- Types: BASIC, UNCOMMON, RARE, UNIQUE

		achievementsCount++;

		if (otherSource == true){
			$("#otherPlayerAchievements").append('<div class="achievementSlot" style = "box-shadow: 0px 4px 10px ' + achievement.color + ';" ><div id="achievement-' + index + '" class="achievement" style = "background-image: url(\'img/achievements/' + achievement.image + '.png\')">' +
			'<div class="achievement-type" style = "color: ' + achievement.color + '; text-shadow: 0 0 5px ' + achievement.color + '" >' + achievement.type + '</div> <div data-tooltip = "' + achievement.description + '"; class="achievement-name" style = "margin-left: 2.8vw;" >' + achievement.title + '</div> </div ><div class="achievement-name-bg"></div></div>');
		
		}else{
			$("#playerAchievements").append('<div class="achievementSlot" style = "box-shadow: 0px 4px 10px ' + achievement.color + ';" ><div id="achievement-' + index + '" class="achievement" style = "background-image: url(\'img/achievements/' + achievement.image + '.png\')">' +
			'<div class="achievement-type" style = "color: ' + achievement.color + '; text-shadow: 0 0 5px ' + achievement.color + '" >' + achievement.type + '</div> <div data-tooltip = "' + achievement.description + '"; class="achievement-name">' + achievement.title + '</div> </div ><div class="achievement-name-bg"></div></div>');
		}
    });

	if (otherSource == true){
		document.getElementById("other_header_character_achievements_title").innerHTML = Locales.profileAchievements + " " + achievementsCount;
	}else{
		document.getElementById("header_character_achievements_title").innerHTML = Locales.profileAchievements + " " + achievementsCount;
	}

}

function inventorySetup(items) {
    $("#playerInventory").html("");
    $.each(items, function (index, item) {
        count = setCount(item);
		
        if (item.type != "item_weapon" && item.type != "item_account"){

			if (item.description != "none") {

				$("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
				'<div class="item-count">' + count + '</div> <div data-tooltip = "' + item.description + '"; class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
			}else{
				
				$("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
				'<div class="item-count">' + count + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
			}
    
		}else if (item.type == "item_weapon" && item.type != "item_account"){
			if (item.description != "none") {
				$("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' + 
				'<div class="item-count">' + count + '</div> <div data-tooltip = "' + item.description + '"; class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
			}else{
				$("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' + 
				'<div class="item-count">' + count + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
			}
		}else{

			if (item.description != "none") {
				$("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
				'<div class="item-count">' + count + '</div> <div data-tooltip = "' + item.description + '"; class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
			}else{
				$("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
				'<div class="item-count">' + count + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
			}
        }
		
        $('#item-' + index).data('item', item);
        $('#item-' + index).data('inventory', "main");
    });
}

function secondPlayerInventorySetup(items, inventoryType) {
    $(inventoryType).html("");

    $.each(items, function (index, item) {
        count = setCount(item);
		
        if (item.type != "item_weapon" && item.type != "item_account"){
            $(inventoryType).append('<div class="secondPlayerSlot"><div id="secondPlayerItem-' + index + '" class="secondPlayerItem" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
            '<div class="secondPlayerItem-count">' + count + '</div> <div class="secondPlayerItem-name">' + item.label + '</div> </div ><div class="secondPlayerItem-name-bg"></div></div>');
        }else if (item.type == "item_weapon" && item.type != "item_account"){
			$(inventoryType).append('<div class="secondPlayerSlot"><div id="secondPlayerItem-' + index + '" class="secondPlayerItem" style = "background-image: url(\'img/items/' + item.name + '.png\')">' + '<div class="secondPlayerItem-count">' + count + '</div> <div class="secondPlayerItem-name">' + item.label + '</div> </div ><div class="secondPlayerItem-name-bg"></div></div>');
		}else{
            $(inventoryType).append('<div class="secondPlayerSlot"><div id="secondPlayerItem-' + index + '" class="secondPlayerItem" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
            '<div class="secondPlayerItem-count">' + count + '</div>' + ' <div class="secondPlayerItem-name">' + item.label + '</div> </div ><div class="secondPlayerItem-name-bg"></div></div>');
        }
		
        $('#secondPlayerItem-' + index).data('secondPlayerItem', item);
        $('#secondPlayerItem-' + index).data('inventory', "main");
    });
}

function secondInventorySetup(items) {
    $("#secondInventory").html("");

    $.each(items, function (index, item) {
        count = setCount(item, true);
		
        if (item.type != "item_weapon" && item.type != "item_account"){
            $("#secondInventory").append('<div class="secondSlot"><div id="secondItem-' + index + '" class="secondItem" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
            '<div class="secondItem-count">' + count + '</div> <div class="secondItem-name">' + item.label + '</div> </div ><div class="secondItem-name-bg"></div></div>');
        }else if (item.type == "item_weapon" && item.type != "item_account"){
			$("#secondInventory").append('<div class="secondSlot"><div id="secondItem-' + index + '" class="secondItem" style = "background-image: url(\'img/items/' + item.name + '.png\')">' + '<div class="secondItem-count">' + count + '</div> <div class="secondItem-name">' + item.label + '</div> </div ><div class="secondItem-name-bg"></div></div>');
		}else{
            $("#secondInventory").append('<div class="secondSlot"><div id="secondItem-' + index + '" class="secondItem" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
            '<div class="secondItem-count">' + count + '</div>' + ' <div class="secondItem-name">' + item.label + '</div> </div ><div class="secondItem-name-bg"></div></div>');
        }
		
        $('#secondItem-' + index).data('secondItem', item);
        $('#secondItem-' + index).data('inventory', "main");
    });
}

function formatMoney(n, c, d, t) {
    var c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(c))),
        j = (j = i.length) > 3 ? j % 3 : 0;

    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t);
};

$(document).ready(function () {
	$("#count").focus(function () {
        $(this).val("")
    }).blur(function () {
        if ($(this).val() == "") {
            $(this).val("1")
        }
    });

	$("body").on("keyup", function (key) {
		// use e.which
		if (key.which == 27){
			closeInventory();
		}
	});

	$('#secondPlayerInventory').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("secondItem");
            itemInventory = ui.draggable.data("inventory");

            disableInventory(500);
            $.post("http://tp-base/TakeFromSecondInventory", JSON.stringify({
				inventoryType : secondInventoryType,
                item: itemData,
                number: parseInt($("#secondCount").val()),
				plate : currentPlate,
				hasTargetSource : secondInventoryHasTargetSource,
				targetSource : secondInventoryTargetSource,
            }));  
        }
    });

    $('#secondInventory').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("secondPlayerItem");
            itemInventory = ui.draggable.data("inventory");

            disableInventory(500);
            $.post("http://tp-base/PutIntoSecondInventory", JSON.stringify({
				inventoryType : secondInventoryType,
                item: itemData,
                number: parseInt($("#secondCount").val()),
				plate : currentPlate,
				hasTargetSource : secondInventoryHasTargetSource,
				targetSource : secondInventoryTargetSource,
            }));
        }
	});

	$('#use').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.usable == undefined) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined) {
                return;
            }

            if (itemData.usable) {
                disableInventory(300);
                $.post("http://tp-base/UseItem", JSON.stringify({
                    item: itemData
                }));
            }
        }
    });

    $('#give').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.canRemove == undefined) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined) {
                return;
            }

            if (itemData.canRemove) {
                disableInventory(300);
                $.post("http://tp-base/GetNearPlayers", JSON.stringify({
                    item: itemData
                }));
            }
        }
    });

	$('.shortcut-slot1').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
			itemData = ui.draggable.data("item");
			
            if (itemData == undefined || itemData.usable == undefined) {
                return;
            }

            for(var i = 0; i < 7; i++){
                if (slots[i] != null ) {
                    if (slots[i].name == itemData.name) return;
                }
            }

            if ((itemData.usable && type == "normal") || itemData.type == "item_weapon") {
                disableInventory(1000);
				
				slots[0] = itemData;
				slotsHtml[0] = '<div class="shortcut-slot"><div id="item-' + 1 + '" class="item" style = "background-image: url(\'img/items/' + itemData.name + '.png\')">' + '<div class="item-count">' + 1 + '</div> <div class="item-name">' + itemData.label + '</div> </div ><div class="item-name-bg"></div></div>'
				
				$(".shortcut-slot1").html(slotsHtml[0]);
            }
        }
    });
	
	$('.shortcut-slot2').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
			itemData = ui.draggable.data("item");
			
            if (itemData == undefined || itemData.usable == undefined) {
                return;
            }

            for(var i = 0; i < 7; i++){
                if (slots[i] != null ) {
                    if (slots[i].name == itemData.name) return;
                }
            }

           if ((itemData.usable && type == "normal") || itemData.type == "item_weapon") {
                disableInventory(1000);
				
				slots[1] = itemData;
				slotsHtml[1] = '<div class="shortcut-slot"><div id="item-' + 2 + '" class="item" style = "background-image: url(\'img/items/' + itemData.name + '.png\')">' + '<div class="item-count">' + 2 + '</div> <div class="item-name">' + itemData.label + '</div> </div ><div class="item-name-bg"></div></div>'
				
				$(".shortcut-slot2").html(slotsHtml[1]);
            }
        }
    });
	
	$('.shortcut-slot3').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
			itemData = ui.draggable.data("item");
			
            if (itemData == undefined || itemData.usable == undefined) {
                return;
            }

            for(var i = 0; i < 7; i++){
                if (slots[i] != null ) {
                    if (slots[i].name == itemData.name) return;
                }
            }

           if ((itemData.usable && type == "normal") || itemData.type == "item_weapon") {
                disableInventory(1000);
				
				slots[2] = itemData;
				slotsHtml[2] = '<div class="shortcut-slot"><div id="item-' + 3 + '" class="item" style = "background-image: url(\'img/items/' + itemData.name + '.png\')">' + '<div class="item-count">' + 3 + '</div> <div class="item-name">' + itemData.label + '</div> </div ><div class="item-name-bg"></div></div>'
				
				$(".shortcut-slot3").html(slotsHtml[2]);
            }
        }
    });
	
	$('.shortcut-slot4').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
			itemData = ui.draggable.data("item");
			
            if (itemData == undefined || itemData.usable == undefined) {
                return;
            }

            for(var i = 0; i < 7; i++){
                if (slots[i] != null ) {
                    if (slots[i].name == itemData.name) return;
                }
            }

           if ((itemData.usable && type == "normal") || itemData.type == "item_weapon") {
                disableInventory(1000);
				
				slots[3] = itemData;
				slotsHtml[3] = '<div class="shortcut-slot"><div id="item-' + 4 + '" class="item" style = "background-image: url(\'img/items/' + itemData.name + '.png\')">' + '<div class="item-count">' + 4 + '</div> <div class="item-name">' + itemData.label + '</div> </div ><div class="item-name-bg"></div></div>'
				
				$(".shortcut-slot4").html(slotsHtml[3]);
            }
        }
    });
	
	$('.shortcut-slot5').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
			itemData = ui.draggable.data("item");
			
            if (itemData == undefined || itemData.usable == undefined) {
                return;
            }

            for(var i = 0; i < 7; i++){
                if (slots[i] != null ) {
                    if (slots[i].name == itemData.name) return;
                }
            }

           if ((itemData.usable && type == "normal") || itemData.type == "item_weapon") {
                disableInventory(1000);
				
				slots[4] = itemData;
				slotsHtml[4] = '<div class="shortcut-slot"><div id="item-' + 5 + '" class="item" style = "background-image: url(\'img/items/' + itemData.name + '.png\')">' + '<div class="item-count">' + 5 + '</div> <div class="item-name">' + itemData.label + '</div> </div ><div class="item-name-bg"></div></div>'
				
				$(".shortcut-slot5").html(slotsHtml[4]);
            }
        }
    });

    $('#drop').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.canRemove == undefined) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined) {
                return;
            }

            if (itemData.canRemove) {
                disableInventory(300);
                $.post("http://tp-base/DropItem", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            }
        }
    });

    $("#count").on("keypress keyup blur", function (event) {
        $(this).val($(this).val().replace(/[^\d].+/, ""));
        if ((event.which < 48 || event.which > 57)) {
            event.preventDefault();
        }
    });
});

$.widget('ui.dialog', $.ui.dialog, {
    options: {
        // Determine if clicking outside the dialog shall close it
        clickOutside: false,
        // Element (id or class) that triggers the dialog opening 
        clickOutsideTrigger: ''
    },
    open: function () {
        var clickOutsideTriggerEl = $(this.options.clickOutsideTrigger),
            that = this;
        if (this.options.clickOutside) {
            // Add document wide click handler for the current dialog namespace
            $(document).on('click.ui.dialogClickOutside' + that.eventNamespace, function (event) {
                var $target = $(event.target);
                if ($target.closest($(clickOutsideTriggerEl)).length === 0 &&
                    $target.closest($(that.uiDialog)).length === 0) {
                    that.close();
                }
            });
        }
        // Invoke parent open method
        this._super();
    },
    close: function () {
        // Remove document wide click handler for the current dialog
        $(document).off('click.ui.dialogClickOutside' + this.eventNamespace);
        // Invoke parent close method 
        this._super();
    },
});