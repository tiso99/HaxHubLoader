--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local FlatIdent_76979 = 0;
			local a;
			while true do
				if (FlatIdent_76979 == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local b = Rep(a, repeatNext);
						repeatNext = nil;
						return b;
					else
						return a;
					end
					break;
				end
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				Exponent = 1;
				IsNormal = 0;
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local FlatIdent_69270 = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_69270 == 3) then
				return Concat(FStr);
			end
			if (FlatIdent_69270 == 0) then
				Str = nil;
				if not Len then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
				end
				FlatIdent_69270 = 1;
			end
			if (FlatIdent_69270 == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_69270 = 3;
			end
			if (FlatIdent_69270 == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_69270 = 2;
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_8D83D = 0;
			local Descriptor;
			while true do
				if (FlatIdent_8D83D == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local Type = gBit(Descriptor, 2, 3);
						local Mask = gBit(Descriptor, 4, 6);
						local Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_1743D = 0;
							while true do
								if (FlatIdent_1743D == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
									break;
								end
							end
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							Inst[3] = gBits32() - (2 ^ 16);
							Inst[4] = gBits16();
						end
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 26) then
					if (Enum <= 12) then
						if (Enum <= 5) then
							if (Enum <= 2) then
								if (Enum <= 0) then
									if (Stk[Inst[2]] == Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum == 1) then
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								else
									local FlatIdent_43862 = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (9 == FlatIdent_43862) then
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_43862 = 10;
										end
										if (FlatIdent_43862 == 1) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_43862 = 2;
										end
										if (FlatIdent_43862 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_43862 = 4;
										end
										if (FlatIdent_43862 == 8) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											FlatIdent_43862 = 9;
										end
										if (FlatIdent_43862 == 10) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_43862 == 7) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_9147D = 0;
												while true do
													if (FlatIdent_9147D == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											FlatIdent_43862 = 8;
										end
										if (FlatIdent_43862 == 2) then
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_43862 = 3;
										end
										if (FlatIdent_43862 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_43862 = 7;
										end
										if (5 == FlatIdent_43862) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_43862 = 6;
										end
										if (FlatIdent_43862 == 0) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_43862 = 1;
										end
										if (4 == FlatIdent_43862) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_43862 = 5;
										end
									end
								end
							elseif (Enum <= 3) then
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
							elseif (Enum > 4) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum <= 8) then
							if (Enum <= 6) then
								Stk[Inst[2]]();
							elseif (Enum == 7) then
								local A;
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							elseif (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 10) then
							if (Enum == 9) then
								local FlatIdent_6A83E = 0;
								local A;
								local B;
								while true do
									if (FlatIdent_6A83E == 1) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										break;
									end
									if (FlatIdent_6A83E == 0) then
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_6A83E = 1;
									end
								end
							else
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							end
						elseif (Enum > 11) then
							local FlatIdent_12544 = 0;
							local A;
							while true do
								if (FlatIdent_12544 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_12544 = 5;
								end
								if (7 == FlatIdent_12544) then
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_12544 == 0) then
									A = nil;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_12544 = 1;
								end
								if (FlatIdent_12544 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_12544 = 4;
								end
								if (FlatIdent_12544 == 6) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_12544 = 7;
								end
								if (FlatIdent_12544 == 1) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									FlatIdent_12544 = 2;
								end
								if (FlatIdent_12544 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_12544 = 3;
								end
								if (5 == FlatIdent_12544) then
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_12544 = 6;
								end
							end
						else
							Stk[Inst[2]] = Env[Inst[3]];
						end
					elseif (Enum <= 19) then
						if (Enum <= 15) then
							if (Enum <= 13) then
								do
									return;
								end
							elseif (Enum > 14) then
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							else
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 17) then
							if (Enum > 16) then
								local FlatIdent_64E40 = 0;
								local A;
								while true do
									if (FlatIdent_64E40 == 0) then
										A = nil;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_64E40 = 1;
									end
									if (7 == FlatIdent_64E40) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
									if (FlatIdent_64E40 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_64E40 = 5;
									end
									if (FlatIdent_64E40 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_64E40 = 3;
									end
									if (FlatIdent_64E40 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_64E40 = 2;
									end
									if (FlatIdent_64E40 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_64E40 = 4;
									end
									if (6 == FlatIdent_64E40) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_64E40 = 7;
									end
									if (5 == FlatIdent_64E40) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_64E40 = 6;
									end
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							end
						elseif (Enum > 18) then
							Upvalues[Inst[3]] = Stk[Inst[2]];
						else
							local A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
						end
					elseif (Enum <= 22) then
						if (Enum <= 20) then
							Stk[Inst[2]] = Inst[3] ~= 0;
						elseif (Enum > 21) then
							if (Stk[Inst[2]] == Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						end
					elseif (Enum <= 24) then
						if (Enum > 23) then
							local A;
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Stk[A + 1]);
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						else
							local A = Inst[2];
							local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							local Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
						end
					elseif (Enum == 25) then
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					else
						Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
					end
				elseif (Enum <= 40) then
					if (Enum <= 33) then
						if (Enum <= 29) then
							if (Enum <= 27) then
								do
									return Stk[Inst[2]]();
								end
							elseif (Enum == 28) then
								local A;
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							else
								local FlatIdent_5B2CE = 0;
								local B;
								local A;
								while true do
									if (2 == FlatIdent_5B2CE) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_5B2CE = 3;
									end
									if (4 == FlatIdent_5B2CE) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_5B2CE = 5;
									end
									if (FlatIdent_5B2CE == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_5B2CE = 1;
									end
									if (FlatIdent_5B2CE == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_5B2CE = 2;
									end
									if (FlatIdent_5B2CE == 6) then
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_5B2CE = 7;
									end
									if (FlatIdent_5B2CE == 3) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_5B2CE = 4;
									end
									if (FlatIdent_5B2CE == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_5B2CE = 6;
									end
									if (FlatIdent_5B2CE == 7) then
										Stk[A] = B[Inst[4]];
										break;
									end
								end
							end
						elseif (Enum <= 31) then
							if (Enum > 30) then
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							end
						elseif (Enum > 32) then
							local FlatIdent_494F6 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_494F6 == 5) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_494F6 = 6;
								end
								if (FlatIdent_494F6 == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_494F6 = 1;
								end
								if (FlatIdent_494F6 == 9) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_494F6 = 10;
								end
								if (FlatIdent_494F6 == 1) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_494F6 = 2;
								end
								if (FlatIdent_494F6 == 3) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_494F6 = 4;
								end
								if (FlatIdent_494F6 == 8) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									FlatIdent_494F6 = 9;
								end
								if (FlatIdent_494F6 == 6) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_494F6 = 7;
								end
								if (FlatIdent_494F6 == 2) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									FlatIdent_494F6 = 3;
								end
								if (FlatIdent_494F6 == 12) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_494F6 = 13;
								end
								if (FlatIdent_494F6 == 11) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_494F6 = 12;
								end
								if (FlatIdent_494F6 == 4) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_494F6 = 5;
								end
								if (13 == FlatIdent_494F6) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									break;
								end
								if (FlatIdent_494F6 == 10) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_494F6 = 11;
								end
								if (FlatIdent_494F6 == 7) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									FlatIdent_494F6 = 8;
								end
							end
						else
							local A = Inst[2];
							Stk[A] = Stk[A]();
						end
					elseif (Enum <= 36) then
						if (Enum <= 34) then
							local FlatIdent_91B54 = 0;
							local A;
							while true do
								if (FlatIdent_91B54 == 0) then
									A = Inst[2];
									do
										return Unpack(Stk, A, Top);
									end
									break;
								end
							end
						elseif (Enum == 35) then
							local FlatIdent_6679B = 0;
							while true do
								if (FlatIdent_6679B == 4) then
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_6679B == 0) then
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6679B = 1;
								end
								if (FlatIdent_6679B == 3) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6679B = 4;
								end
								if (FlatIdent_6679B == 2) then
									Upvalues[Inst[3]] = Stk[Inst[2]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6679B = 3;
								end
								if (FlatIdent_6679B == 1) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_6679B = 2;
								end
							end
						else
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
						end
					elseif (Enum <= 38) then
						if (Enum == 37) then
							local FlatIdent_44603 = 0;
							while true do
								if (FlatIdent_44603 == 0) then
									Stk[Inst[2]] = Inst[3] ~= 0;
									VIP = VIP + 1;
									break;
								end
							end
						else
							local FlatIdent_5724B = 0;
							local A;
							while true do
								if (0 == FlatIdent_5724B) then
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									break;
								end
							end
						end
					elseif (Enum == 39) then
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					else
						Stk[Inst[2]] = Upvalues[Inst[3]];
					end
				elseif (Enum <= 47) then
					if (Enum <= 43) then
						if (Enum <= 41) then
							do
								return Stk[Inst[2]];
							end
						elseif (Enum > 42) then
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						else
							local FlatIdent_8E5B4 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_8E5B4 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_8E5B4 = 5;
								end
								if (0 == FlatIdent_8E5B4) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_8E5B4 = 1;
								end
								if (FlatIdent_8E5B4 == 6) then
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8E5B4 = 7;
								end
								if (2 == FlatIdent_8E5B4) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_8E5B4 = 3;
								end
								if (FlatIdent_8E5B4 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_8E5B4 = 2;
								end
								if (FlatIdent_8E5B4 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_8E5B4 = 4;
								end
								if (FlatIdent_8E5B4 == 5) then
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_8E5B4 = 6;
								end
								if (FlatIdent_8E5B4 == 7) then
									Stk[Inst[2]] = Inst[3];
									break;
								end
							end
						end
					elseif (Enum <= 45) then
						if (Enum == 44) then
							local A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						elseif (Stk[Inst[2]] ~= Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum == 46) then
						local A = Inst[2];
						do
							return Unpack(Stk, A, A + Inst[3]);
						end
					else
						local FlatIdent_4E551 = 0;
						local NewProto;
						local NewUvals;
						local Indexes;
						while true do
							if (FlatIdent_4E551 == 0) then
								NewProto = Proto[Inst[3]];
								NewUvals = nil;
								FlatIdent_4E551 = 1;
							end
							if (FlatIdent_4E551 == 1) then
								Indexes = {};
								NewUvals = Setmetatable({}, {__index=function(_, Key)
									local FlatIdent_803FB = 0;
									local Val;
									while true do
										if (FlatIdent_803FB == 0) then
											Val = Indexes[Key];
											return Val[1][Val[2]];
										end
									end
								end,__newindex=function(_, Key, Value)
									local Val = Indexes[Key];
									Val[1][Val[2]] = Value;
								end});
								FlatIdent_4E551 = 2;
							end
							if (2 == FlatIdent_4E551) then
								for Idx = 1, Inst[4] do
									local FlatIdent_55D83 = 0;
									local Mvm;
									while true do
										if (FlatIdent_55D83 == 1) then
											if (Mvm[1] == 4) then
												Indexes[Idx - 1] = {Stk,Mvm[3]};
											else
												Indexes[Idx - 1] = {Upvalues,Mvm[3]};
											end
											Lupvals[#Lupvals + 1] = Indexes;
											break;
										end
										if (FlatIdent_55D83 == 0) then
											VIP = VIP + 1;
											Mvm = Instr[VIP];
											FlatIdent_55D83 = 1;
										end
									end
								end
								Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
								break;
							end
						end
					end
				elseif (Enum <= 50) then
					if (Enum <= 48) then
						local FlatIdent_30F75 = 0;
						local A;
						local Cls;
						while true do
							if (0 == FlatIdent_30F75) then
								A = Inst[2];
								Cls = {};
								FlatIdent_30F75 = 1;
							end
							if (1 == FlatIdent_30F75) then
								for Idx = 1, #Lupvals do
									local List = Lupvals[Idx];
									for Idz = 0, #List do
										local Upv = List[Idz];
										local NStk = Upv[1];
										local DIP = Upv[2];
										if ((NStk == Stk) and (DIP >= A)) then
											Cls[DIP] = NStk[DIP];
											Upv[1] = Cls;
										end
									end
								end
								break;
							end
						end
					elseif (Enum > 49) then
						local B;
						local A;
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
					elseif Stk[Inst[2]] then
						VIP = VIP + 1;
					else
						VIP = Inst[3];
					end
				elseif (Enum <= 52) then
					if (Enum == 51) then
						local B;
						local A;
						Stk[Inst[2]] = Upvalues[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						do
							return;
						end
					else
						Stk[Inst[2]] = Upvalues[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						if (Stk[Inst[2]] == Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					end
				elseif (Enum == 53) then
					Stk[Inst[2]] = Inst[3];
				else
					VIP = Inst[3];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!073O00028O00026O00F03F027O0040026O00084003043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572004A3O0012353O00014O000F000100083O0026163O0016000100020004363O00160001001235000900013O0026160009000B000100020004363O000B00012O000F000500053O00062F00053O000100012O00043O00023O001235000900033O0026160009000F000100030004363O000F00010012353O00033O0004363O0016000100261600090005000100010004363O000500012O000F000400043O00062F00040001000100012O00043O00023O001235000900023O0004363O00050001000E080004002900013O0004363O002900012O000F000800083O00062F00080002000100042O00043O00054O00043O00034O00043O00064O00043O00074O0004000900044O0004000A00034O00120009000200020006310009002600013O0004363O002600012O0004000900084O00060009000100010004363O004800012O0004000900074O00060009000100010004363O004800010026163O0034000100010004363O003400012O000F000100013O00022B000100034O001C000900016O0009000100024O000200093O00122O000900053O00202O00090009000600202O00030009000700124O00023O0026163O0002000100030004363O00020001001235000900013O000E080001003C000100090004363O003C00012O000F000600063O00022B000600043O001235000900023O000E0800020042000100090004363O004200012O000F000700073O00062F00070005000100012O00043O00033O001235000900033O000E0800030037000100090004363O003700010012353O00043O0004363O000200010004363O003700010004363O000200012O00308O000D3O00013O00067O0002084O002800026O0001000200023O00062D00020005000100010004363O000500012O002500026O0014000200014O0029000200024O000D3O00017O00023O0003043O004E616D650001094O002800015O00201000023O00012O000100010001000200261600010006000100020004363O000600012O002500016O0014000100014O0029000100024O000D3O00017O002C3O0003083O00496E7374616E63652O033O006E657703093O005363722O656E47756903063O00506172656E7403043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572030C3O0057616974466F724368696C6403093O00506C6179657247756903053O004672616D6503043O0053697A6503053O005544696D32028O00026O006940026O00594003083O00506F736974696F6E026O00E03F026O0059C0026O0049C003103O004261636B67726F756E64436F6C6F723303063O00436F6C6F7233026O00F03F03093O00546578744C6162656C026O003440026O0034C003043O005465787403113O00484158485542204B65792053797374656D030A3O0054657874436F6C6F7233030A3O00496E707574426567616E03073O00436F2O6E656374030C3O00496E7075744368616E676564030A3O00496E707574456E646564030A3O004765745365727669636503103O0055736572496E7075745365727669636503073O0054657874426F78030D3O00456E74657220746865204B657903163O004261636B67726F756E645472616E73706172656E6379030B3O00546578745772612O7065642O01030A3O005465787442752O746F6E03063O005375626D697403013O005803113O004D6F75736542752O746F6E31436C69636B03073O00476574204B657900F83O00120A3O00013O00206O000200122O000100038O0002000200122O000100053O00202O00010001000600202O00010001000700202O00010001000800122O000300096O00010003000200104O0004000100122O000100013O00202O00010001000200122O0002000A6O00010002000200122O0002000C3O00202O00020002000200122O0003000D3O00122O0004000E3O00122O0005000D3O00122O0006000F6O00020006000200102O0001000B000200122O0002000C3O00202O00020002000200122O000300113O00122O000400123O00122O000500113O00122O000600136O00020006000200102O00010010000200122O000200153O00202O00020002000200122O000300163O00122O000400163O00122O000500166O00020005000200102O00010014000200102O000100043O00122O000200013O00202O00020002000200122O000300176O00020002000200122O0003000C3O00202O00030003000200122O000400163O00122O0005000D3O00122O0006000D3O00122O000700186O00030007000200102O0002000B000300122O0003000C3O00202O00030003000200122O0004000D3O00122O0005000D3O00122O0006000D3O00122O000700196O00030007000200102O00020010000300302O0002001A001B00122O000300153O00202O00030003000200122O000400163O00122O000500163O00122O000600166O00030006000200102O0002001C000300122O000300153O00202O00030003000200122O0004000D3O00122O0005000D3O00122O0006000D6O00030006000200102O00020014000300102O0002000400014O000300063O00062F00073O000100032O00043O00054O00043O00014O00043O00063O00201000080002001D00200900080008001E00062F000A0001000100042O00043O00064O00043O00014O00043O00034O00043O00054O00240008000A000100201000080002001F00200900080008001E00062F000A0002000100012O00043O00044O00240008000A000100201000080002002000200900080008001E00062F000A0003000100022O00043O00034O00043O00044O001D0008000A000100122O000800053O00202O00080008002100122O000A00226O0008000A000200202O00080008001F00202O00080008001E00062F000A0004000100032O00043O00044O00043O00034O00043O00074O00180008000A000100122O000800013O00202O00080008000200122O000900236O00080002000200122O0009000C3O00202O00090009000200122O000A00163O00122O000B000D3O00122O000C00113O00122O000D000D6O0009000D000200102O0008000B000900122O0009000C3O00202O00090009000200122O000A000D3O00122O000B000D3O00122O000C000D3O00122O000D000D6O0009000D000200102O00080010000900302O0008001A002400122O000900153O00202O00090009000200122O000A000D3O00122O000B000D3O00122O000C000D6O0009000C000200102O0008001C000900302O00080025001100122O000900153O00202O00090009000200122O000A00163O00122O000B00163O00122O000C00166O0009000C000200102O00080014000900302O00080026002700102O00080004000100122O000900013O00202O00090009000200122O000A00286O00090002000200122O000A000C3O00202O000A000A000200122O000B00113O00122O000C000D3O00122O000D00113O00122O000E000D6O000A000E000200102O0009000B000A00122O000A000C3O00202O000A000A000200122O000B000D3O00122O000C000D3O00122O000D00113O00122O000E000D6O000A000E000200102O00090010000A00302O0009001A002900102O00090004000100122O000A00013O00202O000A000A000200122O000B00286O000A0002000200122O000B000C3O00202O000B000B000200122O000C000D3O00122O000D00183O00122O000E000D3O00122O000F00186O000B000F000200102O000A000B000B00122O000B000C3O00202O000B000B000200122O000C00163O00122O000D00193O00122O000E000D3O00122O000F000D6O000B000F0002001015000A0010000B003032000A001A002A00122O000B00153O00202O000B000B000200122O000C00163O00122O000D00163O00122O000E00166O000B000E000200102O000A001C000B00122O000B00153O00202O000B000B000200122O000C00163O00122O000D000D3O00122O000E000D6O000B000E000200102O000A0014000B00102O000A0004000100202O000B000A002B00202O000B000B001E00062F000D0005000100012O00048O0021000B000D000100122O000B00013O00202O000B000B000200122O000C00286O000B0002000200122O000C000C3O00202O000C000C000200122O000D00113O00122O000E000D3O00122O000F00113O00122O0010000D6O000C0010000200102O000B000B000C00122O000C000C3O00202O000C000C000200122O000D00113O00122O000E000D3O00122O000F00113O00122O0010000D6O000C0010000200102O000B0010000C00302O000B001A002C00102O000B0004000100202O000C0009002B00202O000C000C001E00062F000E0006000100062O00043O00084O00288O00283O00014O00048O00283O00024O00283O00034O0024000C000E0001002010000C000B002B002009000C000C001E00022B000E00074O0024000C000E00012O000D3O00013O00083O00083O00028O0003083O00506F736974696F6E03053O005544696D322O033O006E657703013O005803053O005363616C6503063O004F2O6673657403013O0059011F3O001235000100014O000F000200023O000E0800010002000100010004363O0002000100201000033O00022O000700048O0002000300044O000300013O00122O000400033O00202O0004000400044O000500023O00202O00050005000500202O0005000500064O000600023O00202O00060006000500202O00060006000700202O0007000200054O0006000600074O000700023O00202O00070007000800202O0007000700064O000800023O00202O00080008000800202O00080008000700202O0009000200084O0008000800094O00040008000200102O00030002000400044O001E00010004363O000200012O000D3O00017O00093O00030D3O0055736572496E7075745479706503043O00456E756D030C3O004D6F75736542752O746F6E3103053O00546F756368028O00026O00F03F03083O00506F736974696F6E03073O004368616E67656403073O00436F2O6E65637401283O00201900013O000100122O000200023O00202O00020002000100202O00020002000300062O0001000C000100020004363O000C000100201000013O000100120B000200023O00201000020002000100201000020002000400062O00010027000100020004363O00270001001235000100054O000F000200023O0026160001000E000100050004363O000E0001001235000200053O0026160002001D000100060004363O001D00012O0028000300013O0020100003000300072O001300035O00201000033O000800200900030003000900062F00053O000100022O00048O00283O00024O00240003000500010004363O0027000100261600020011000100050004363O001100012O0014000300014O0023000300023O00202O00033O00074O000300033O00122O000200063O00044O001100010004363O002700010004363O000E00012O000D3O00013O00013O00033O00030E3O0055736572496E707574537461746503043O00456E756D2O033O00456E64000A4O00347O00206O000100122O000100023O00202O00010001000100202O00010001000300064O0009000100010004363O000900012O00148O00133O00014O000D3O00017O00043O00030D3O0055736572496E7075745479706503043O00456E756D030D3O004D6F7573654D6F76656D656E7403053O00546F756368010E3O00201900013O000100122O000200023O00202O00020002000100202O00020002000300062O0001000C000100020004363O000C000100201000013O000100120B000200023O00201000020002000100201000020002000400062O0001000D000100020004363O000D00012O00138O000D3O00017O00053O00030D3O0055736572496E7075745479706503043O00456E756D030C3O004D6F75736542752O746F6E3103053O00546F756368028O00011C3O00201900013O000100122O000200023O00202O00020002000100202O00020002000300062O0001000C000100020004363O000C000100201000013O000100120B000200023O00201000020002000100201000020002000400062O0001001B000100020004363O001B0001001235000100054O000F000200023O0026160001000E000100050004363O000E0001001235000200053O00261600020011000100050004363O001100012O001400036O001300036O000F000300034O0013000300013O0004363O001B00010004363O001100010004363O001B00010004363O000E00012O000D3O00019O002O00010A4O002800015O00064O0009000100010004363O000900012O0028000100013O0006310001000900013O0004363O000900012O0028000100024O000400026O00260001000200012O000D3O00017O00013O0003073O0044657374726F7900044O00287O0020095O00012O00263O000200012O000D3O00017O00043O0003043O005465787403043O004E616D65028O0003073O0044657374726F7900174O00117O00206O00014O000100016O000200023O00202O0002000200024O00038O00010003000200062O0001001400013O0004363O00140001001235000100033O0026160001000A000100030004363O000A00012O0028000200033O00200E0002000200044O0002000200014O000200046O00020001000100044O001600010004363O000A00010004363O001600012O0028000100054O00060001000100012O000D3O00017O00023O00030C3O00736574636C6970626F61726403233O005061737465206865726520796F7572206C696E6B20746F2067657420746865206B657900043O00120B3O00013O001235000100024O00263O000200012O000D3O00017O00083O00028O0003483O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F7469736F2O392F4861784875624C6F616465722F6D61696E2F77686974656C6973742E6C756103043O0067616D6503073O00482O7470476574026O00F03F030A3O006C6F6164737472696E6703053O00652O726F72031F3O004661696C656420746F206C6F61642077686974656C69737420736372697074001D3O0012353O00014O000F000100033O000E080001000B00013O0004363O000B0001001235000100023O00122A000400033O00202O0004000400044O000600016O0004000600024O000200043O00124O00053O000E080005000200013O0004363O0002000100120B000400064O0004000500024O00120004000200022O0004000300043O0006310003001700013O0004363O001700012O0004000400034O001B000400014O002200045O0004363O001C000100120B000400073O001235000500084O00260004000200010004363O001C00010004363O000200012O000D3O00017O000B3O00028O00026O00F03F03053O007072696E74030E3O004C6F6164656420312O302F312O30030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403213O00682O7470733A2O2F706173746562696E2E636F6D2F7261772F6E7535322O76304503173O0057686974656C697374656421204C6F6164696E673O2E03043O0077616974026O660240001F3O0012353O00014O000F000100013O0026163O0002000100010004363O00020001001235000100013O00261600010012000100020004363O0012000100120B000200033O001202000300046O00020002000100122O000200053O00122O000300063O00202O00030003000700122O000500086O000300056O00023O00024O00020001000100044O001E000100261600010005000100010004363O0005000100120B000200033O00120C000300096O00020002000100122O0002000A3O00122O0003000B6O00020002000100122O000100023O00044O000500010004363O001E00010004363O000200012O000D3O00017O00023O0003043O004B69636B030F3O004E6F742057686974656C697374656400054O00337O00206O000100122O000200028O000200016O00017O00", GetFEnv(), ...);
